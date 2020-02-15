//
//  CurrencyPair.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 15/02/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//

import Foundation

class CurrencyPair {
    var baseCurrency: String
    var foreignCurrency: String
    var exchangeRate: Double = 0.0
    
    init(baseCurr: String, foreignCurr: String) {
        self.baseCurrency = baseCurr
        self.foreignCurrency = foreignCurr
        
        NetworkService.shared.fetchData(from: "https://api.exchangeratesapi.io/latest?symbols=\(foreignCurrency)&base=\(baseCurrency)") { result in
            switch result {
            case .success(let str):
                print(str)
                let decoder = JSONDecoder()
                if let rateObject = try? decoder.decode(ExchangeRate.self, from: str) {
                    print(rateObject)
                    if let rate = rateObject.rates[self.foreignCurrency] {
                        self.exchangeRate = rate
                        print(rate)
                    }
                }
            case .failure(let error):
                switch error {
                case .badURL:
                    print("Bad URL")
                case .requestFailed:
                    print("Bad URL")
                case .unknown:
                    print("Unknown error")
                }
            }
        }
        
    }
    
    // {"rates":{"USD":1.3029997116},"base":"GBP","date":"2020-02-14"}
}

struct ExchangeRate: Codable {
    var rates: [String: Double]
    var base: String
    var date: String
}
