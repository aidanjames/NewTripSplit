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
