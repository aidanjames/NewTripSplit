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
    var image: Image?
    var circleShape: Bool = true
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            ZStack {
                if circleShape {
                    Circle()
                        .stroke(Color.green, lineWidth: 1)
                        .foregroundColor(Color(.secondarySystemBackground))
//                        .shadow(color: Color(hex: "D1CDC7").opacity(colorScheme == .dark ? 0 : 1), radius: 4, x: 4, y: 4)
//                        .shadow(color: Color(hex: "FFFFFF").opacity(colorScheme == .dark ? 0 : 1), radius: 4, x: -4, y: -4)
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundColor(Color(.secondarySystemBackground))
//                        .shadow(color: Color(hex: "D1CDC7").opacity(colorScheme == .dark ? 0 : 1), radius: 4, x: 4, y: 4)
//                        .shadow(color: Color(hex: "FFFFFF").opacity(colorScheme == .dark ? 0 : 1), radius: 4, x: -4, y: -4)
                }
                
                if onButtonImage != nil {
                    Image(systemName: onButtonImage!)
                        .font(.largeTitle)
                } else if onButtonText != nil {
                    Text(onButtonText!)
                } else if image != nil {
                    image!
                        .resizable()
                        .scaledToFit()
                        .frame(height: 55)
                }
            }
            .frame(width: width, height: height)
            if belowButtonText != nil {
                Text(belowButtonText!)
            }
        }
        .foregroundColor(.green)
    }
}

struct NeumorphicButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            NeumorphicButton(width: 100, height: 100, belowButtonText: "New transaction", onButtonImage: "plus")
            NeumorphicButton(width: 80, height: 80, belowButtonText: "Side bets", image: Image("cardsLARGE"))
        }
    }
}
