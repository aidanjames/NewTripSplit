//
//  TransactionListView.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 03/01/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//

import SwiftUI

struct TransactionListItemView: View {
    
    @ObservedObject var transaction: Transaction
    
    @State private var paidForNames = [String]()
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(transaction.wrappedTitle)
                Text("Paid by \(transaction.paidBy?.firstName ?? "Unknown") for \(ListFormatter.localizedString(byJoining: paidForNames)).")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text("\(Currencies.format(currency: transaction.trip?.baseCurrency ?? "Error", amount: transaction.baseAmt, withSymbol: true, withSign: true))")
                if transaction.baseAmt != transaction.trnAmt { // Foreign transaction
                    Text("\(Currencies.format(currency: transaction.trnCurrency ?? "Unknown", amount: transaction.trnAmt, withSymbol: true, withSign: true))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
        }
        .onAppear(perform: populatePaidForNames)
    }
    
    func populatePaidForNames() {
        guard paidForNames.isEmpty else { return }
        for person in transaction.paidForArray {
            paidForNames.append(person.firstName)
        }
    }
}


struct TransactionListItemView_Previews: PreviewProvider {
    static var previews: some View {
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let person = Person(context: moc)
        person.id = UUID()
        person.name = "Stormzy Smith"
        let person2 = Person(context: moc)
        person2.id = UUID()
        person2.name = "Peter Sucker"
        let transaction = Transaction(context: moc)
        transaction.id = UUID()
        transaction.title = "Shopping"
        transaction.paidBy = person
        transaction.addToPaidFor(person2)
        transaction.baseAmt = 45.23
        transaction.trnAmt = 50.00
        transaction.exchangeRate = 1.234543
        transaction.trnCurrency = "EUR"
        return TransactionListItemView(transaction: transaction)
            .previewLayout(.sizeThatFits)
    }
}

