//
//  NeumorphicButton.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 31/01/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//

import SwiftUI

struct NeumorphicButton: View {
    
    var width: CGFloat
    var height: CGFloat
    var text: String
    var image: String?
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .foregroundColor(Color(hex: "EFEEEE"))
                    .shadow(color: Color(hex: "D1CDC7"), radius: 5, x: 6, y: 6)
                    .shadow(color: Color(hex: "FFFFFF"), radius: 5, x: -6, y: -6)
                if image != nil {
                    Image(systemName: image!)
                        .font(.largeTitle)
                }
                
            }
            .frame(width: width, height: height)
            Text(text)
        }
        .foregroundColor(.blue)
    }
}

struct NeumorphicButton_Previews: PreviewProvider {
    static var previews: some View {
        NeumorphicButton(width: 100, height: 100, text: "New transaction", image: "plus")
    }
}
