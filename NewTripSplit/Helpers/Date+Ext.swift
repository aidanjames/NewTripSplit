//
//  Date+Ext.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 06/10/2021.
//  Copyright © 2021 Aidan Pendlebury. All rights reserved.
//

import Foundation

extension Date {
    
    func convertToString() -> String {
        let formatter1 = DateFormatter()
        formatter1.dateStyle = .short
        return formatter1.string(from: self)
    }
}
