//
//  Currencies.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 03/01/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//

import Foundation

public enum Currencies: String, CaseIterable {
    case gbp = "GBP"
    case eur = "EUR"
    
    static func format(currency: String = "GBP", amount: Double, withSymbol: Bool = true, withSign: Bool = true) -> String {
        
        
        
        var currencySymbol: String {
            switch currency {
            case "GBP":
                return "£"
            case "EUR":
                return "€"
            default:
                return "$"
            }
        }
        
        var symbol: String {
            var returnString = ""
            if withSymbol {
                returnString += currencySymbol
            }
            return returnString
        }
        
        var sign: String {
            var returnString = ""
            if amount < 0 {
                returnString += "-"
            }
            return returnString
        }
        
        return String(format: "\(sign)\(symbol)%.02f", abs(amount))
        
    }
}
