//
//  SettlementRecord.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 02/09/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//

import CoreData
import SwiftUI

struct SettlementRecordsView: View {
    
    var moc: NSManagedObjectContext
    var account: Trip
    
    @State private var settlementData: [SettlementRecord] = []
    @State private var showingPostTransactionAlert = false
    
    @State private var settlementLockedIn = false
    
    // Adding these to get around the bug where the wrong record is being sent to the alert screen on selecting the settle button
    @State private var settleRecordId: UUID?
    @State private var payingFrom: Person?
    @State private var payingTo: Person?
    @State private var amount: Double?
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                
                Section(header: Text("")) {
                    // Empty state
                    if settlementData.isEmpty { Text("All settled 🙂") }
                    // Should really do an 'else' but I'm a bit lazy and it's not strictly necessary.
                    ForEach(settlementData) { record in
                        HStack {
                            Group {
                                Text("\(record.from.wrappedName)").bold().strikethrough(record.paid)
                                    + Text(" pays ").strikethrough(record.paid)
                                    + Text("\(record.to.wrappedName): ").bold().strikethrough(record.paid)
                                    + Text("\(String(format: "%.02f", (abs(record.amount))))").bold().strikethrough(record.paid)
                                
                            }.foregroundColor(record.paid ? .secondary : .primary)
                            .alert(isPresented: $showingPostTransactionAlert) {
                                // There's a bug here where it is not recognising the correct record so I'm temporarily saving the record in context using @State variables.
                                Alert(title: Text("Post transaction?"), message: Text("This will post a settlement transaction for \(String(format: "%.02f", (abs(amount != nil ? amount! : 0)))) from \(payingFrom?.wrappedName ?? "Error") to \(payingTo?.wrappedName ?? "Error")"), primaryButton: .destructive(Text("Confirm"), action: {
                                    saveExpense()
                                    
                                    print("The selected record is \(record.from.wrappedName) to \(record.to.wrappedName)")
                                    if let index = settlementData.firstIndex(where: { $0.id == settleRecordId }) {
                                        settlementData[index].paid = true
                                    }
                                    account.saveSettlement(settlementData)
                                    showingPostTransactionAlert = false
                                }), secondaryButton: .cancel())
                                
                            }
                            
                            Spacer()
                            
                            if !record.paid {
                                Text("Settle")
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(Color.blue)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .onTapGesture {
                                        settleRecordId = record.id
                                        payingFrom = record.from
                                        payingTo = record.to
                                        amount = abs(record.amount)
                                        showingPostTransactionAlert = true
                                    }
                            } else {
                                Text("Settled 🙂")
                            }
                            
                            
                        }
                    }
                }
//                Section {
//                    Button("Save settlement") {
//                        account.saveSettlement(settlementData)
//                    }
//                    Button("Delete saved settlement") {
//                        account.deleteSettlement()
//                    }
//                    Button("Re-calculate settlement") {
//                        account.deleteSettlement()
//                        settlementData = account.calculateSettlement2()
//                        account.saveSettlement(settlementData)
//                    }
//                }
            }
            .navigationBarTitle(Text("Settlement"))
            .navigationBarItems(trailing: Button("Done") { presentationMode.wrappedValue.dismiss() })
            .onAppear {
                // Check if we have a asved settlement...
                if let savedSettlement = account.fetchSavedLockedInSettlement() {
                    for record in savedSettlement {
                        print("From: \(record.from.wrappedName) To: \(record.to.wrappedName) Amount: Paid: \(record.paid ? "true" : "false")")
                    }
                    settlementData = savedSettlement
                } else {
                    settlementData = account.calculateSettlement2()
                    account.saveSettlement(settlementData)
                }

            }
            
        }
        .accentColor(.green)
    }
    
    
    func saveExpense() {
        
        guard payingFrom != nil, payingTo != nil, amount != nil else { return }
        
        // Create the transaction
        let transaction = Transaction(context: moc)
        transaction.id = UUID()
        transaction.title = "Settlement from \(payingFrom!.wrappedName) to \(payingTo!.wrappedName)"
        transaction.additionalInfo = "Settlement transaction."
        transaction.baseAmt = amount!
        transaction.trnAmt = amount!
        transaction.trip = account
        transaction.trnCurrency = account.baseCurrency
        transaction.date = Date()

        
        // Increase the balance of the person paying
        transaction.paidBy = payingFrom!
        if let payingFrom = account.sortedPeopleArray.firstIndex(where: { $0.id == payingFrom?.id }) {
            account.sortedPeopleArray[payingFrom].localBal += amount!
        }
                
        // Reduce the balance of beneficiary
        transaction.addToPaidFor(payingTo!)
        if let payingTo = account.sortedPeopleArray.firstIndex(where: { $0.id == payingTo?.id }) {
            account.sortedPeopleArray[payingTo].localBal -= amount!
        }
        
        try? moc.save()
    }

    func checkIfSettlementLockedIn(completion: () -> Void) {
        // try to load existing settlement data (will be stored using file manager)
        if let settlementRecords = account.fetchSavedLockedInSettlement() {
            settlementData = settlementRecords
            completion()
        } else {
            completion()
        }
    }
    
}

struct SettlementRecordsView_Previews: PreviewProvider {
    static var previews: some View {
        
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let trip = Trip(context: moc)
        trip.id = UUID()
        trip.name = "Preview trip"
        trip.image = "trip"
        let person = Person(context: moc)
        person.id = UUID()
        person.name = "Dale"
        let person1 = Person(context: moc)
        person1.id = UUID()
        person1.name = "Sharon"
        person1.photo = "person2"
        trip.addToPeople(person)
        trip.addToPeople(person1)
        
        return SettlementRecordsView(moc: moc, account: trip)
    }
}
