//
//  Double+Ext.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 06/10/2021.
//  Copyright © 2021 Aidan Pendlebury. All rights reserved.
//

import Foundation

extension Double {
    
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    func convertToString(decimals: Int) -> String {
        return String(self.rounded(toPlaces: decimals))
    }
    
}
