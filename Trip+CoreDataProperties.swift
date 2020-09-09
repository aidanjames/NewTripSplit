//
//  Trip+CoreDataProperties.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 03/01/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//
//

import Foundation
import CoreData
import SwiftUI

extension Trip {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Trip> {
        return NSFetchRequest<Trip>(entityName: "Trip")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var dateCreated: Date?
    @NSManaged public var image: String?
    @NSManaged public var name: String?
    @NSManaged public var baseCurrency: String?
    @NSManaged public var currenciesUsed: [String]?
    @NSManaged public var people: NSSet?
    @NSManaged public var transactions: NSSet?
    
    public var wrappedId: UUID { id ?? UUID() }
    public var wrappedDateCreated: Date { dateCreated ?? Date() }
    public var wrappedName: String { name ?? "Unknown name" }
    public var wrappedBaseCurrency: String { baseCurrency ?? "GBP" }
    public var wrappedCurrenciesUsed: [String] { currenciesUsed ?? ["GBP"] }

    public var sortedPeopleArray: [Person] {
        let set = people as? Set<Person> ?? []

        return set.sorted { (first, second) -> Bool in
           if first.localBal < second.localBal {
              return true
           } else if first.localBal > second.localBal {
              return false
           } else if first.wrappedName < second.wrappedName { // If balance is the same, sort by name.
              return true
           }
           return false
        }  
    }
    
    public var wrappedAccountImage: Image {
        if let imageName = image {
            if let imageData: Data = FileManager.default.fetchData(from: imageName) {
                if let uiImage = UIImage(data: imageData) {
                    return Image(uiImage: uiImage)
                }
            }
        }
        return Image(wrappedBaseCurrency.prefix(3).lowercased())
    }
    
    public var transactionsArray: [Transaction] {
        let set = transactions as? Set<Transaction> ?? []
        return set.sorted {
            $0.wrappedDate < $1.wrappedDate
        }
    }

}

// MARK: Generated accessors for people
extension Trip {

    @objc(addPeopleObject:)
    @NSManaged public func addToPeople(_ value: Person)

    @objc(removePeopleObject:)
    @NSManaged public func removeFromPeople(_ value: Person)

    @objc(addPeople:)
    @NSManaged public func addToPeople(_ values: NSSet)

    @objc(removePeople:)
    @NSManaged public func removeFromPeople(_ values: NSSet)

}

// MARK: Generated accessors for transactions
extension Trip {

    @objc(addTransactionsObject:)
    @NSManaged public func addToTransactions(_ value: Transaction)

    @objc(removeTransactionsObject:)
    @NSManaged public func removeFromTransactions(_ value: Transaction)

    @objc(addTransactions:)
    @NSManaged public func addToTransactions(_ values: NSSet)

    @objc(removeTransactions:)
    @NSManaged public func removeFromTransactions(_ values: NSSet)

}

// MARK: Function to calculate settlement
extension Trip {
    func calculateSettlement() -> [String] {
        var returnArray = [String]()
        guard self.sortedPeopleArray.count > 1 else {
            returnArray.append("Only one person, no one to pay.")
            return returnArray
        }
        guard self.transactions?.count ?? 0 > 0 else {
            returnArray.append("There's no transactions for this account.")
            return returnArray
        }
        var memberDictionary = [Person: Double]()
        for member in self.sortedPeopleArray {
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
                        returnArray.append("\(firstPerson.firstName) pays \(lastPerson.firstName) \(Currencies.format(amount: Double(abs(lastPersonBalance))))")
                        sortedMemberDictionary[0].value = firstPersonBalance + lastPersonBalance
                        sortedMemberDictionary.remove(at: sortedMemberDictionary.count - 1)
                    } else if Double(abs(firstPersonBalance)) < Double(abs(lastPersonBalance)) {
                        returnArray.append("\(firstPerson.firstName) pays \(lastPerson.firstName) \(Currencies.format(amount: Double(abs(firstPersonBalance))))")
                        sortedMemberDictionary[sortedMemberDictionary.count - 1].value = lastPersonBalance + firstPersonBalance
                        sortedMemberDictionary.remove(at: 0)
                    } else if Double(abs(firstPersonBalance)) == Double(abs(lastPersonBalance)) {
                        returnArray.append("\(firstPerson.firstName) pays \(lastPerson.firstName)  \(Currencies.format(amount: Double(abs(lastPersonBalance))))")
                        sortedMemberDictionary.remove(at: sortedMemberDictionary.count - 1)
                        sortedMemberDictionary.remove(at: 0)
                    }
                }
            }
        }
        return returnArray
    }
    
    
    func calculateSettlement2() -> [SettlementRecord] {
        
        // Create the empty return array
        var returnArray = [SettlementRecord]()
        
        // Get out of here if there's only one person in the account
        guard self.sortedPeopleArray.count > 1 else {
            return returnArray
        }
        
        // Get out of here if there's no transactions
        guard self.transactions?.count ?? 0 > 0 else {
            return returnArray
        }
        
        // Create a dictionary of all members, with the person as Key and their balance as the value
        var memberDictionary = [Person: Double]()
        for member in self.sortedPeopleArray {
            memberDictionary[member] = member.localBal
        }
        
        // Get rid of memers with no balance (or almost no balance to cover for precision issues)
        let filteredMemberDictionary = memberDictionary.filter( { $0.value < -0.001 || $0.value > 0.001 } )
        
        // Sort the members by their balance, people with most debt first.
        var sortedMemberDictionary = filteredMemberDictionary.sorted(by: { $0.value  <  $1.value } )
        
        while sortedMemberDictionary.count > 1 {
            
            // Get the first person (owes the most) and last person (owed the most)
            if let firstPerson = sortedMemberDictionary.first?.key,
                let lastPerson = sortedMemberDictionary.last?.key {
                
                // Get the respective balance of the first and last person
                if let firstPersonBalance = sortedMemberDictionary.first?.value,
                    let lastPersonBalance = sortedMemberDictionary.last?.value {
                    
                    // If the first person owes more than the last person is owed, the first person pays all the money owed to the last person.
                    if Double(abs(firstPersonBalance)) > Double(abs(lastPersonBalance)) {
                        if abs(lastPerson.localBal) > 0.01 {
                            // Write a record to the return array accordingly
                            returnArray.append(SettlementRecord(from: firstPerson, to: lastPerson, amount: lastPersonBalance))
                            // Reduce the first person's balance by the amount of the last person's balance
                            sortedMemberDictionary[0].value = firstPersonBalance + lastPersonBalance
                        }

                        // Remove the last person from the dictionary (as their balance will be settled in full)
                        sortedMemberDictionary.remove(at: sortedMemberDictionary.count - 1)
                        
                    // If the first person owes less than what the last person is owed, the first person pays their entire debt to the last person
                    } else if Double(abs(firstPersonBalance)) < Double(abs(lastPersonBalance)) {
                        if abs(firstPerson.localBal) > 0.01 {
                            // Write a record to the return array accordingly
                            returnArray.append(SettlementRecord(from: firstPerson, to: lastPerson, amount: firstPersonBalance))
                            // Reduce the last person's balance by the amount of the first person's balance
                            sortedMemberDictionary[sortedMemberDictionary.count - 1].value = lastPersonBalance + firstPersonBalance
                        }
                        // Remove the first person from the dictionary (as their balance is settled in full)
                        sortedMemberDictionary.remove(at: 0)
                        
                    // If the first person's balance is the same as the last person's balance, the first person pays the last person their full balance
                    } else if Double(abs(firstPersonBalance)) == Double(abs(lastPersonBalance)) {
                        // Write a record to the return array accordingly
                        returnArray.append(SettlementRecord(from: firstPerson, to: lastPerson, amount: firstPerson.localBal))
                        // Remove the last person from the dictionary (as their balance will be settled in full)
                        sortedMemberDictionary.remove(at: sortedMemberDictionary.count - 1)
                        // Remove the first person from the dictionary (as their balance will be settled in full)
                        sortedMemberDictionary.remove(at: 0)
                    }
                }
            }
        }
        return returnArray
    }
    
    
    func saveSettlement() {
        // Save [SettlementRecord] to file manager
    }
    
    func deleteSettlement() {
        // Delete [SettlementRecord] from file manager, if exists
    }
    
    
    func fetchSavedLockedInSettlement() -> [SettlementRecord]? {
        // Check file manager for saved settlement position
        // If exists, return the array
        // If not, return nil
        return nil
    }
    
}
