//
//  BalancePosition.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 11/09/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//

import Foundation

enum BalancePosition: String {
    case owes, owed, allSquare
    
    static func forPerson(_ person: Person) -> BalancePosition {
        if person.localBal < -0.01 {
            return .owes
        } else if person.localBal > 0.01 {
            return .owed
        }
        return .allSquare
    }
}
