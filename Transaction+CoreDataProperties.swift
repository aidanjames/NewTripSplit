//
//  Transaction+CoreDataProperties.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 03/01/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//
//

import Foundation
import CoreData


extension Transaction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }

    @NSManaged public var baseAmt: Double
    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var photo: String?
    @NSManaged public var trnAmt: Double
    @NSManaged public var exchangeRate: Double
    @NSManaged public var additionalInfo: String?
    @NSManaged public var trnCurrency: String?
    @NSManaged public var paidBy: Person?
    @NSManaged public var paidFor: NSSet?
    @NSManaged public var trip: Trip?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    
    public var wrappedDate: Date { date ?? Date() }
    public var wrappedId: UUID { id ?? UUID() }
    public var wrappedTitle: String { title ?? "Unknown title" }
    public var wrappedAdditionalInfo: String { additionalInfo ?? "" }
    public var wrappedTrnCurrency: String { trnCurrency ?? "Unknown currency" }
    
    public var paidForArray: [Person] {
        let set = paidFor as? Set<Person> ?? []
        return set.sorted {
            $0.wrappedName < $1.wrappedName
        }
    }
    
    public var dateDisplay: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: wrappedDate)
    }
    
    public var trnCurrencyAmt: Double {
        return trnAmt * exchangeRate
    }


}

// MARK: Generated accessors for paidFor
extension Transaction {

    @objc(addPaidForObject:)
    @NSManaged public func addToPaidFor(_ value: Person)

    @objc(removePaidForObject:)
    @NSManaged public func removeFromPaidFor(_ value: Person)

    @objc(addPaidFor:)
    @NSManaged public func addToPaidFor(_ values: NSSet)

    @objc(removePaidFor:)
    @NSManaged public func removeFromPaidFor(_ values: NSSet)

}

// MARK: Extension for comparable protocol conformance
extension Transaction {
    public static func < (lhs: Transaction, rhs: Transaction) -> Bool {
        lhs.wrappedDate < rhs.wrappedDate
    }
}
