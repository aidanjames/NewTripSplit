//
//  Currencies.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 03/01/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//

import Foundation

public enum Currencies: String, CaseIterable {
    case gbp = "GBP - British pound"
    case eur = "EUR - Euro"
    case usd = "USD - US dollar"
    case nzd = "NZD - NZ dollar"
    case aud = "AUD - Australian dollar"
    case cad = "CAD - Canadian dollar"
    case hkd = "HKD - HK dollar"
    case dkk = "DKK - Danish kroner"
    case idr = "INR - Indian rupee"
    
    static func format(currency: String = "GBP", amount: Double, withSymbol: Bool = true, withSign: Bool = true) -> String {
        
       var currencySymbol: String {
            switch currency {
            case "GBP - British pound", "GBP":
                return "£"
            case "EUR - Euro", "EUR":
                return "€"
            case "HKD - HK dollar", "HKD":
                return "HK$"
            case "DKK - Danish kroner", "DKK":
                return "Kr"
            case "INR - Indian rupee", "INR":
                return "₹"
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
    
    static func symbol(for currency: String) -> String {
        switch currency {
        case "GBP - British pound", "GBP":
            return "£"
        case "EUR - Euro", "EUR":
            return "€"
        case "HKD - HK dollar", "HKD":
            return "HK$"
        case "DKK - Danish kroner", "DKK":
            return "Kr"
        case "INR - Indian rupee", "INR":
            return "₹"
        default:
            return "$"
        }
    }
}
