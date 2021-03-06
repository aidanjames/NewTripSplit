//
//  AccountCardView.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 01/02/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//

import CoreData
import SwiftUI

struct AccountCardView: View {
    
    @Environment(\.managedObjectContext) var moc
    @ObservedObject var account: Trip
    
    @State private var showingDeleteWarning = false
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.green, lineWidth: 1)
                .foregroundColor(Color(.secondarySystemBackground))
                .shadow(color: Color(hex: "D1CDC7").opacity(colorScheme == .dark ? 0 : 1), radius: 5, x: 5, y: 5)
            HStack(spacing: 8) {
                account.wrappedAccountImage
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding()
                VStack(alignment: .leading) {
                    HStack {
                        Text(account.wrappedName)
                            .font(.system(size: 25))
                            .fontWeight(.bold)
                            .lineLimit(2)
                        Spacer()
                    }
                    Group {
                        Text("\(account.people?.count ?? 0) Participants")
                        Text("\(account.transactionsArray.count) Transactions")
//                        Text("Total spent: \(Currencies.format(currency: account.baseCurrency ?? "Error", amount: account.transactionsArray.reduce(0) { $0 + $1.baseAmt }, withSymbol: true, withSign: true))")
                    }
                    .foregroundColor(.secondary)
                }
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, minHeight: 150, idealHeight: 150, maxHeight: .infinity)
        .padding(.horizontal)
        .padding(.top, 18)
    }
    
}

struct AccountCardView_Previews: PreviewProvider {
    static var previews: some View {
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let trip = Trip(context: moc)
        trip.id = UUID()
        trip.name = "This trip"
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
        return AccountCardView(account: trip).environment(\.managedObjectContext, moc)
    }
}
