//
//  Category.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 04/03/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//

import Foundation

public enum Category: String, CaseIterable {
    case general = "General"
    case eatingOut = "Eating out"
    case groceries = "Groceries"
    case drinks = "Drinks"
    case entertainment = "Entertainment"
    
    func matchCategory(from word: String) -> String {
        if word.lowercased().contains("beers") { return Category.drinks.rawValue}
        return Category.general.rawValue
    }
}
