//
//  CurrencyPair.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 15/02/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//

import Foundation

class CurrencyPair: ObservableObject {
    
    static let shared = CurrencyPair()
    
    var baseCurrency: String = ""
    var foreignCurrency: String = ""
    
    @Published var error: String? // Add some error handling to the add transaction view
    @Published var exchangeRate: Double = 0.0
    
    private init() { }
        
    
    func getExchangeRate() {
        NetworkService.shared.fetchData(from: "https://api.exchangeratesapi.io/latest?symbols=\(foreignCurrency)&base=\(baseCurrency)") { result in
            switch result {
            case .success(let str):
                let decoder = JSONDecoder()
                if let rateObject = try? decoder.decode(ExchangeRate.self, from: str) {
                    print(rateObject)
                    if let rate = rateObject.rates[self.foreignCurrency] {
                        self.exchangeRate = rate
                        self.error = nil
                    }
                }
            case .failure(let error):
                switch error {
                case .badURL:
                    print("Bad URL")
                    self.error = error.localizedDescription
                case .requestFailed:
                    print("Bad URL")
                    self.error = error.localizedDescription
                case .unknown:
                    print("Unknown error")
                    self.error = error.localizedDescription
                }
            }
        }
    }
}

struct ExchangeRate: Codable {
    var rates: [String: Double]
    var base: String
    var date: String
}
