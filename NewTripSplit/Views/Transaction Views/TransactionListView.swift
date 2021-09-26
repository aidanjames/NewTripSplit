//
//  TransactionListView.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 10/01/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//

import CoreData
import SwiftUI

struct TransactionListView: View {
    
    @Binding var bottomSheetIsOpen: Bool
    var geoSize: CGSize
    var moc: NSManagedObjectContext
    @ObservedObject var trip: Trip
    @State private var showingTransactionDetailView = false
    @Environment(\.colorScheme) var colorScheme
    
    var dates: [String] { // Consider moving this to a function
        let dateDic = Dictionary(grouping: trip.transactionsArray) { $0.dateDisplay }
        var dateArray = [String]()
        for date in dateDic {
            dateArray.append(date.key)
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateArray.sorted {dateFormatter.date(from: $0)! > dateFormatter.date(from: $1)!}
    }
    
    var body: some View {
        
        BottomSheetView(isOpen: $bottomSheetIsOpen, maxHeight: geoSize.height) {
            if trip.transactionsArray.isEmpty {
                Text("No expenses to display")
            }
            List {
                ForEach(dates, id: \.self) { date in
                    Section(header: Text(date)) {
                        ForEach(trip.transactionsArray.filter { $0.dateDisplay == date }.sorted(by: >), id: \.self) { transaction in
                            Button(action: showTransactionDetailView) {
                                TransactionListItemView(transaction: transaction)
                            }
                            .sheet(isPresented: $showingTransactionDetailView) {
                                TransactionDetailView(transaction: transaction, trip: trip, moc: moc)
                            }
                        }
                    }
                }
            }
            .colorMultiply(colorScheme == .dark ? .white : Color(.secondarySystemBackground))
            .disabled(!bottomSheetIsOpen)
        }
    }
    
    func showTransactionDetailView() {
        showingTransactionDetailView.toggle()
    }
}

struct TransactionListView_Previews: PreviewProvider {
    
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
        
        trip.addToTransactions(transaction)
        
        let transaction2 = Transaction(context: moc)
        transaction2.id = UUID()
        transaction2.title = "Taxi"
        transaction2.baseAmt = 30.00
        transaction2.exchangeRate = 0
        transaction2.trnAmt = 30.00
        transaction2.date = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        transaction2.trip = trip
        transaction2.paidBy = person
        transaction2.addToPaidFor(person1)
        
        trip.addToTransactions(transaction2)
        
        let transaction3 = Transaction(context: moc)
        transaction3.id = UUID()
        transaction3.title = "Hotel"
        transaction3.baseAmt = 150.56
        transaction3.exchangeRate = 0
        transaction3.trnAmt = 150.56
        transaction3.date = Date()
        transaction3.trip = trip
        transaction3.paidBy = person
        transaction3.addToPaidFor(person1)
        
        trip.addToTransactions(transaction3)
        
        return TransactionListView(bottomSheetIsOpen: .constant(true), geoSize: CGSize(width: 300, height: 850), moc: moc, trip: trip)
            .previewLayout(.sizeThatFits)
    }
}
