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
    
    var body: some View {
        VStack {
            ForEach(whoPaysWhoArray, id: \.self) { record in
                Text(record)
            }
        }
        .onAppear(perform: calculateSettlement)
    }
    
    func calculateSettlement(){
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
        while filteredMemberDictionary.count > 1 {
            if let firstPerson = sortedMemberDictionary.first,
                let lastPerson = sortedMemberDictionary.last {
                let firstPersonBalance = firstPerson.value
                let lastPersonBalance = lastPerson.value
                if Double(abs(firstPersonBalance)) > Double(abs(lastPersonBalance)) {
                    self.whoPaysWhoArray.append("\(firstPerson.key.firstName) pays \(lastPerson.key.firstName)  \(String(format: "%.2f", Double(abs(lastPersonBalance))))")
                    sortedMemberDictionary[0].value = firstPersonBalance + lastPersonBalance
                    sortedMemberDictionary.remove(at: sortedMemberDictionary.count - 1)
                } else if Double(abs(firstPersonBalance)) < Double(abs(lastPersonBalance)) {
                    self.whoPaysWhoArray.append("\(firstPerson.key.firstName) pays \(lastPerson.key.firstName)  \(String(format: "%.2f",Double(abs(firstPersonBalance))))")
                    sortedMemberDictionary[sortedMemberDictionary.count - 1].value = lastPersonBalance + firstPersonBalance
                    sortedMemberDictionary.remove(at: 0)
                } else if Double(abs(firstPersonBalance)) == Double(abs(lastPersonBalance)) {
                    self.whoPaysWhoArray.append("\(firstPerson.key.firstName) pays \(lastPerson.key.firstName)  \(String(format: "%.2f",Double(abs(lastPersonBalance))))")
                    sortedMemberDictionary.remove(at: sortedMemberDictionary.count - 1)
                    sortedMemberDictionary.remove(at: 0)
                }
            }
        }
    }
    
    
    //    func getPaymentRecords() -> [String] {
    //        guard self.people.count > 1 else {
    //            return ["Only one person, nobody to pay!"]
    //        }
    //        guard self.expenses.count > 0 else {
    //            return ["No expenses, nothing to pay!"]
    //        }
    //        var folksDict = [Person: Double]()
    //        for person in self.people {
    //            folksDict[person] = person.ledgers[0].amount
    //        }
    //        let filteredFolksDict = folksDict.filter( { $0.value < -0.001 || $0.value > 0.001 } )
    //        var sortedFolksDict = filteredFolksDict.sorted(by: { $0.value  <  $1.value } )
    //        var payStrings = [String]()
    //        while sortedFolksDict.count > 1 {
    //            if let firstPerson = sortedFolksDict.first,
    //                let lastPerson = sortedFolksDict.last {
    //                let firstPersonBalance = firstPerson.value
    //                let lastPersonBalance = lastPerson.value
    //                if Double(abs(firstPersonBalance)) > Double(abs(lastPersonBalance)) {
    //                    payStrings.append("\(firstPerson.key.name) pays \(lastPerson.key.name) \(self.localCurrency!.currencyCode) \(String(format: "%.2f", Double(abs(lastPersonBalance))))")
    //                    sortedFolksDict[0].value = firstPersonBalance + lastPersonBalance
    //                    sortedFolksDict.remove(at: sortedFolksDict.count - 1)
    //                } else if Double(abs(firstPersonBalance)) < Double(abs(lastPersonBalance)) {
    //                    payStrings.append("\(firstPerson.key.name) pays \(lastPerson.key.name) \(self.localCurrency!.currencyCode) \(String(format: "%.2f",Double(abs(firstPersonBalance))))")
    //                    sortedFolksDict[sortedFolksDict.count - 1].value = lastPersonBalance + firstPersonBalance
    //                    sortedFolksDict.remove(at: 0)
    //                } else if Double(abs(firstPersonBalance)) == Double(abs(lastPersonBalance)) {
    //                    payStrings.append("\(firstPerson.key.name) pays \(lastPerson.key.name) \(self.localCurrency!.currencyCode) \(String(format: "%.2f",Double(abs(lastPersonBalance))))")
    //                    sortedFolksDict.remove(at: sortedFolksDict.count - 1)
    //                    sortedFolksDict.remove(at: 0)
    //                }
    //            }
    //        }
    //        return payStrings
    //    }
    
    
    
    
    
    
    
    
    
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
