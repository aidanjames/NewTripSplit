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
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("")) {
                    ForEach(settlementData) { record in
                        HStack {
                            Group {
                                Text("\(record.from.wrappedName)").bold().strikethrough(record.paid)
                                    + Text(" pays ").strikethrough(record.paid)
                                    + Text("\(record.to.wrappedName): ").bold().strikethrough(record.paid)
                                    + Text("\(String(format: "%.02f", (abs(record.amount))))").bold().strikethrough(record.paid)
                                
                            }.foregroundColor(record.paid ? .secondary : .primary)
                            .alert(isPresented: $showingPostTransactionAlert) {
                                Alert(title: Text("Post transaction?"), message: Text("This will post a settlement transaction for \(String(format: "%.02f", (abs(record.amount)))) from \(record.from.wrappedName) to \(record.to.wrappedName)"), primaryButton: .destructive(Text("Live dangerously"), action: {
                                    // TODO: Post transaction
                                    // There's a bug here where it is not recognising the correct record.
                                    print("The selected record is \(record.from.wrappedName) to \(record.to.wrappedName)")
                                    if let index = settlementData.firstIndex(where: { $0.id == record.id }) {
                                        settlementData[index].paid = true
                                    }
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
                                        // TODO: POST THE TRANSACTION!!!...
                                        showingPostTransactionAlert = true
                                        print("The selected record is \(record.from.wrappedName) to \(record.to.wrappedName)")
                                        
                                    }
                                    

                                
                            } else {
                                Text("Settled 🙂")
                            }
                            
                            
                        }
                    }
                }
            }
            .navigationBarTitle(Text("Settlement"))
            .navigationBarItems(trailing: Button("Done") { presentationMode.wrappedValue.dismiss() })
            .onAppear { settlementData = account.calculateSettlement2() }
            
        }
        .accentColor(.green)
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
