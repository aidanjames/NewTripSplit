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
    var belowButtonText: String?
    var onButtonText: String?
    var onButtonImage: String?
    var circleShape: Bool = true
    
    var body: some View {
        VStack {
            ZStack {
                if circleShape {
                    Circle()
                    .foregroundColor(Color(hex: "EFEEEE"))
                    .shadow(color: Color(hex: "D1CDC7"), radius: 4, x: 4, y: 4)
                    .shadow(color: Color(hex: "FFFFFF"), radius: 4, x: -4, y: -4)
                } else {
                    RoundedRectangle(cornerRadius: 16)
                    .foregroundColor(Color(hex: "EFEEEE"))
                    .shadow(color: Color(hex: "D1CDC7"), radius: 4, x: 4, y: 4)
                    .shadow(color: Color(hex: "FFFFFF"), radius: 4, x: -4, y: -4)
                }
                    
                if onButtonImage != nil {
                    Image(systemName: onButtonImage!)
                        .font(.largeTitle)
                } else if onButtonText != nil {
                    Text(onButtonText!)
                }
            }
            .frame(width: width, height: height)
            if belowButtonText != nil {
                Text(belowButtonText!)
            }
        }
        .foregroundColor(.blue)
    }
}

struct NeumorphicButton_Previews: PreviewProvider {
    static var previews: some View {
        NeumorphicButton(width: 100, height: 100, belowButtonText: "New transaction", onButtonImage: "plus")
    }
}
