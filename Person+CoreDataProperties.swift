//
//  Person+CoreDataProperties.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 03/01/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//
//

import Foundation
import CoreData
import SwiftUI

extension Person {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Person> {
        return NSFetchRequest<Person>(entityName: "Person")
    }
    
    @NSManaged public var id: UUID?
    @NSManaged public var localBal: Double
    @NSManaged public var name: String?
    @NSManaged public var photo: String?
    @NSManaged public var beneficiary: NSSet?
    @NSManaged public var payer: NSSet?
    @NSManaged public var trip: Trip?
    @NSManaged public var isSelected: Bool
    @NSManaged public var hasLeft: Bool
    
    public var wrappedId: UUID { id ?? UUID() }
    public var wrappedName: String {
        if let name = name {
            return name.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            return "Unknown name"
        }
    }
    
    public var beneficiaryArray: [Transaction] {
        let set = beneficiary as? Set<Transaction> ?? []
        return set.sorted {
            $0.wrappedDate < $1.wrappedDate
        }
    }
    
    public var payerArray: [Transaction] {
        let set = payer as? Set<Transaction> ?? []
        return set.sorted {
            $0.wrappedDate < $1.wrappedDate
        }
    }
    
    public var firstName: String {
        let nameAsArray = wrappedName.components(separatedBy: " ")
        return nameAsArray[0]
    }
    
    public var displayLocalBal: String {
        if localBal < -0.01 {
            return String(format: "Owes %.02f", abs(localBal))
        } else if localBal > 0.01 {
            return String(format: "Owed %.02f", abs(localBal))
        }
        return "All square"
    }
    
    public var displayLocalBalWithSign: String {
        if localBal > -0.01 && localBal < 0.01 {
            return "All square"
        }
        return String(format: "%.02f", localBal)
    }
    
    
    public var wrappedMemberImage: Image {
        if let imageName = photo {
            if let imageData: Data = FileManager.default.fetchData(from: imageName) {
                if let uiImage = UIImage(data: imageData) {
                    return Image(uiImage: uiImage)
                }
            }
        }
        return Image("unknown")
    }
    
    
}


// MARK: Generated accessors for beneficiary
extension Person {
    
    @objc(addBeneficiaryObject:)
    @NSManaged public func addToBeneficiary(_ value: Transaction)
    
    @objc(removeBeneficiaryObject:)
    @NSManaged public func removeFromBeneficiary(_ value: Transaction)
    
    @objc(addBeneficiary:)
    @NSManaged public func addToBeneficiary(_ values: NSSet)
    
    @objc(removeBeneficiary:)
    @NSManaged public func removeFromBeneficiary(_ values: NSSet)
    
}

// MARK: Generated accessors for payee
extension Person {
    
    @objc(addPayeeObject:)
    @NSManaged public func addToPayer(_ value: Transaction)
    
    @objc(removePayeeObject:)
    @NSManaged public func removeFromPayer(_ value: Transaction)
    
    @objc(addPayee:)
    @NSManaged public func addToPayer(_ values: NSSet)
    
    @objc(removePayee:)
    @NSManaged public func removeFromPayer(_ values: NSSet)
    
}

// MARK: Toggle function for isSelected property
extension Person {
    
    func toggleIsSelected() {
        self.isSelected = !self.isSelected
    }
}

