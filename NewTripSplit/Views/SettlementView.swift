//
//  SettlementView.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 05/02/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//

import CoreData
import SwiftUI

struct SettlementView: View {
    
    var moc: NSManagedObjectContext
    var account: Trip
    
    @State private var whoPaysWhoArray = [String]()
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(whoPaysWhoArray, id: \.self) { record in
                        Text(record)
                    }
                }
            }
            .onAppear(perform: calculateSettlement)
            .navigationBarTitle(Text("Settlement"))
            .navigationBarItems(trailing: Button("Done") { self.presentationMode.wrappedValue.dismiss() })
        }
    }
    
    func calculateSettlement() {
        guard account.sortedPeopleArray.count > 1 else {
            self.whoPaysWhoArray.append("Only one person, no one to pay.")
            return
        }
        guard account.transactions?.count ?? 0 > 0 else {
            self.whoPaysWhoArray.append("There's no transactions for this account.")
            return
        }
        var memberDictionary = [Person: Double]()
        for member in account.sortedPeopleArray {
            memberDictionary[member] = member.localBal
        }
        let filteredMemberDictionary = memberDictionary.filter( { $0.value < -0.001 || $0.value > 0.001 } )
        var sortedMemberDictionary = filteredMemberDictionary.sorted(by: { $0.value  <  $1.value } )
        while sortedMemberDictionary.count > 1 {
            if let firstPerson = sortedMemberDictionary.first?.key,
                let lastPerson = sortedMemberDictionary.last?.key {
                if let firstPersonBalance = sortedMemberDictionary.first?.value,
                    let lastPersonBalance = sortedMemberDictionary.last?.value {
                    if Double(abs(firstPersonBalance)) > Double(abs(lastPersonBalance)) {
                        self.whoPaysWhoArray.append("\(firstPerson.firstName) pays \(lastPerson.firstName) \(Currencies.format(amount: Double(abs(lastPersonBalance))))")
                        sortedMemberDictionary[0].value = firstPersonBalance + lastPersonBalance
                        sortedMemberDictionary.remove(at: sortedMemberDictionary.count - 1)
                    } else if Double(abs(firstPersonBalance)) < Double(abs(lastPersonBalance)) {
                        self.whoPaysWhoArray.append("\(firstPerson.firstName) pays \(lastPerson.firstName) \(Currencies.format(amount: Double(abs(firstPersonBalance))))")
                        sortedMemberDictionary[sortedMemberDictionary.count - 1].value = lastPersonBalance + firstPersonBalance
                        sortedMemberDictionary.remove(at: 0)
                    } else if Double(abs(firstPersonBalance)) == Double(abs(lastPersonBalance)) {
                        self.whoPaysWhoArray.append("\(firstPerson.firstName) pays \(lastPerson.firstName)  \(Currencies.format(amount: Double(abs(lastPersonBalance))))")
                        sortedMemberDictionary.remove(at: sortedMemberDictionary.count - 1)
                        sortedMemberDictionary.remove(at: 0)
                    }
                }
            }
        }
    }
    
}

struct SettlementView_Previews: PreviewProvider {
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
        
        return SettlementView(moc: moc, account: trip)
    }
}
