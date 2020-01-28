//
//  Odds.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 15/01/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//

import Foundation

struct Odds: Codable, Identifiable { //}, Comparable {
    var id = UUID()
    var dateCreated = Date()
    var tripId: UUID // Will be the id of the trip
    var offeredById: UUID // Will be the id of the person
    var condition: String
    var odds: Double
    var maxPot: Double
    var wagers = [Wager]()
    var betStatus = BetStatus.active
    
    var fractionalOdds: String {
        let numbers = Fractions.fraction(from: odds - 1)
        return "\(numbers.0)/\(numbers.1)"
    }
    
    static func fractionalOddsFrom(double: Double) -> String {
        guard double > 0 else { return "-/-"}
        let numbers = Fractions.fraction(from: double - 1)
        return "\(numbers.0)/\(numbers.1)"
    }
    
}


enum BetStatus: String, Codable {
    case active = "Active"
    case paid = "Paid"
    case notPaid = "Did not pay"
    case cancelled = "Cancelled"
}

fileprivate enum Fractions {
    static func fraction(from double: Double, withPrecision eps: Double = 1.0E-6) -> (Int, Int) {
        var x = double
        var a = floor(x)
        var (h1, k1, h, k) = (1, 0, Int(a), 1)
        
        while x - a > eps * Double(k) * Double(k) {
            x = 1.0/(x - a)
            a = floor(x)
            (h1, k1, h, k) = (h, k, h1 + Int(a) * h, k1 + Int(a) * k)
        }
        return (h, k)
    }
}
