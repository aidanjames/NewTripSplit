//
//  UIApplicationExtension.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 23/01/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//

import SwiftUI

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
