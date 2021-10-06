//
//  CSVGenerator.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 06/10/2021.
//  Copyright © 2021 Aidan Pendlebury. All rights reserved.
//

import Foundation

enum CSVGenerator {
    
    static func transactionsToCSVString(transactions: [Transaction]) -> String {
        
        var csvString = ""
        var titleString = "Date,Description,Paid_by,Beneficiaries,Base_amount,Local_currency,Local_amount,Exchange rate,"
        
        var beneficiariesArray = [String]()
        for transaction in transactions {
            for person in transaction.paidForArray {
                beneficiariesArray.append(person.wrappedName)
            }
        }
        
        let beneficiariesSet = Set(beneficiariesArray)
        let newBensArray = Array(beneficiariesSet)
        
        var count1 = 1
        for beneficiary in newBensArray {
            titleString.append(beneficiary)
            if count1 < newBensArray.count {
                titleString.append(",")
            }
            count1 += 1
        }
        csvString.append("\(titleString)\n")
        
        for transaction in transactions {
            csvString.append(transaction.wrappedDate.convertToString())
            csvString.append(",")
            csvString.append(transaction.wrappedTitle)
            csvString.append(",")
            csvString.append(transaction.paidBy!.wrappedName)
            csvString.append(",")
            
            var beneficiariesString = "\""
            for beneficiary in transaction.paidForArray {
                beneficiariesString.append(beneficiary.wrappedName)
                if beneficiary.wrappedId != transaction.paidForArray[transaction.paidForArray.count - 1].wrappedId {
                    beneficiariesString.append(", ")
                }
            }
            beneficiariesString.append("\"")
            csvString.append(beneficiariesString)
            csvString.append(",")
            csvString.append(String(transaction.baseAmt.convertToString(decimals: 2)))
            if transaction.trnCurrency != nil {
                csvString.append(",")
                csvString.append(String(transaction.wrappedTrnCurrency.prefix(3)))
                csvString.append(",")
                csvString.append(Currencies.format(currency: transaction.trnCurrency ?? "Unknown", amount: transaction.trnAmt, withSymbol: false, withSign: true))
                csvString.append(",")
                csvString.append(transaction.exchangeRate.convertToString(decimals: 6))
                csvString.append(",")
            }
            
            var bensOfThisTransactionArray = [String]()
            
            for person in transaction.paidForArray {
                bensOfThisTransactionArray.append(person.wrappedName)
            }
            
            var count2 = 1
            for benficiary in newBensArray {
                if bensOfThisTransactionArray.contains(benficiary) {
                    csvString.append((transaction.baseAmt / Double(transaction.paidForArray.count)).convertToString(decimals: 2))
                } else {
                    csvString.append("0.00")
                }
                if count2 < newBensArray.count {
                    csvString.append(",")
                }
                count2 += 1
            }
            
            csvString.append("\n")
            
        }
        
        return csvString
    }
    
}
