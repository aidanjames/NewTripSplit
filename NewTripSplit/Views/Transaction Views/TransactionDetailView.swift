//
//  TransactionDetailView.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 25/01/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//

import CoreData
import CoreLocation
import MapKit
import SwiftUI

struct TransactionDetailView: View {
    
    var transaction: Transaction?
    var trip: Trip
    var moc: NSManagedObjectContext
    
    @State private var centerCoordinate = CLLocationCoordinate2D()
    @State private var showingDeleteAlert = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var annotation: MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.coordinate = centerCoordinate
        annotation.title = "\(transaction?.wrappedTitle ?? "Unknown")"
        annotation.subtitle = ""
        return annotation
    }
    
    var body: some View {
        NavigationView {
            if transaction != nil {
                GeometryReader { geo in
                    VStack(spacing: 0) {
                        if self.annotation.coordinate.longitude != 0 && self.annotation.coordinate.latitude != 0 {
                            MapView(centreCoordinate: self.$centerCoordinate, annotation: self.annotation)
                                .frame(width: geo.size.width, height: geo.size.height * 0.3)
                        }
                        
                        List {
                            Section(header: Text("Transaction details")) {
                                Text("\(self.transaction!.wrappedTitle)")
                                if !(self.transaction!.wrappedAdditionalInfo.isEmpty) {
                                    Text("\(self.transaction!.wrappedAdditionalInfo)")
                                }
                                Text("Amount: \(Currencies.format(amount: self.transaction!.baseAmt))")
                                Text("Date: \(self.transaction!.dateDisplay)")
                            }
                            Section(header: Text("Paid by")) {
                                Text("\(self.transaction!.paidBy?.wrappedName ?? "")")
                            }
                            Section(header: Text("Beneficiaries")) {
                                ForEach(self.transaction!.paidForArray, id: \.self) { person in
                                    Text(person.wrappedName)
                                }
                                
                                
                            }
                            
                        }
                        
                        Spacer()
                    }
                    .onAppear(perform: self.populateCenterCoordinate)
                    .navigationBarTitle("\(self.transaction?.wrappedTitle ?? "Unknown")", displayMode: .inline)
                    .navigationBarItems(trailing:
                        Button(action: { self.showingDeleteAlert.toggle() }) {
                            Image(systemName: "trash")
                                .padding(3)
                        }
                    )
                        .alert(isPresented: self.$showingDeleteAlert) {
                            Alert(title: Text("Delete transaction?"), message: Text("Are you sure you want to delete this transaction. All members balances will be updated."), primaryButton: .destructive(Text("Delete transaction")) {
                                self.presentationMode.wrappedValue.dismiss()
                                
                                // This is a hack because the screen won't dismiss whilst I'm deleting the transaction.
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    self.deleteTransaction()
                                }
                                
                                }, secondaryButton: .cancel())
                    }
                    
                }
            }
            
        }
    }
    
    func populateCenterCoordinate() {
        if transaction?.latitude != 0 && transaction?.longitude != 0 {
            self.centerCoordinate = CLLocationCoordinate2D(latitude: transaction?.latitude ?? 0, longitude: transaction?.longitude ?? 0)
        }
    }
    
    func deleteTransaction() {
        
        if let transaction = transaction {
            // reduce the balance of the paid for user
            if let paidByIndex = trip.sortedPeopleArray.firstIndex(where: { $0.wrappedId == transaction.paidBy?.wrappedId }) {
                let person = trip.sortedPeopleArray[paidByIndex]
                
                person.localBal -= transaction.baseAmt
            }
            
            // Increase the balance of all the beneficiaries
            for person in transaction.paidForArray {
                if let paidForIndex = trip.sortedPeopleArray.firstIndex(where: { $0.wrappedId == person.wrappedId }) {
                    let person = trip.sortedPeopleArray[paidForIndex]
                    person.localBal += (transaction.baseAmt / Double(transaction.paidForArray.count))
                }
            }
            
            // Delete the transaction
            moc.delete(transaction)
            try? self.moc.save()
        }
        
        
    }
    
}

struct TransactionDetailView_Previews: PreviewProvider {
    
    
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
        
        let transaction = Transaction(context: moc)
        transaction.id = UUID()
        transaction.title = "Chips"
        transaction.baseAmt = 24.34
        transaction.exchangeRate = 0
        transaction.trnAmt = 24.34
        transaction.date = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        transaction.trip = trip
        transaction.paidBy = person
        transaction.addToPaidFor(person1)
        transaction.latitude = 51.413423
        transaction.longitude = -0.177426
        
        return TransactionDetailView(transaction: transaction, trip: trip, moc: moc)
    }
}
