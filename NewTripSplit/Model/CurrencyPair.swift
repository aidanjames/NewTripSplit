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
        
        // https://api.exchangerate.host/latest?base=GBP&symbols=EUR&v=2021-03-23
        
        // Get today's date and format it correctly for the API request (so we don't get back a cached repsponse).
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())
        
        NetworkService.shared.fetchData(from: "https://api.exchangerate.host/latest?base=\(baseCurrency)&symbols=\(foreignCurrency)&v=\(today)") { result in
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
                    print("Bad URL .badURL")
                    self.error = error.localizedDescription
                case .requestFailed:
                    print("Bad URL2 .requestFailed")
                    self.error = error.localizedDescription
                case .unknown:
                    print("Unknown error")
                    self.error = error.localizedDescription
                }
            }
        }
    }
    
    
    func manuallySetExchangeRate(_ rate: String) {
        if let rate = Double(rate) {
            self.exchangeRate = rate
            self.error = nil
        }
    }
}

struct ExchangeRate: Codable {
    var rates: [String: Double]
    var base: String
    var date: String
}


