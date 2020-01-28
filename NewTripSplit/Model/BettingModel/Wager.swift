//
//  Wager.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 15/01/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//

import Foundation

struct Wager: Codable, Identifiable {
    var id = UUID()
    var wagedById: UUID // WIll be the id of the person
    var amountWaged: Double
    var odds: Odds
    
    var paysAmount: Double {
        return (self.amountWaged * self.odds.odds) - self.amountWaged
    }
    
//    var fractionalOdds: String {
//        // 3.00 == 2/1 (because you get the 2 back as well as the 1 you bet (ridiculous!))
//        
//        /* To convert decimal odds to fractional,
//         subtract 1.00 and then find the nearest whole integers
//         (so 3.75 - 1.00 becomes 2.75/1, or 11/4).
//         */
//        let numbers = Fractions.fraction(from: paysAmount - 1)
//        
//        return "\(numbers.0)/\(numbers.1)"
//    }
//    
//    static func fractionalOddsFrom(double: Double) -> String {
//        let numbers = Fractions.fraction(from: double - 1)
//        return "\(numbers.0)/\(numbers.1)"
//    }

}


