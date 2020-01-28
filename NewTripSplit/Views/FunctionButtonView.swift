//
//  FunctionButtonView.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 06/01/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//

import SwiftUI

struct FunctionButtonView: View {
    
    var width: CGFloat
    var height: CGFloat
    var text: String
    var image: String?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .frame(width: width, height: height)
                .foregroundColor(Color(hex: "#ff7f50"))
            VStack {
                Text(text)
                    .fontWeight(.bold)
                if image != nil {
                    Image(systemName: image!)
                    .font(.largeTitle)
                }
            }
            .foregroundColor(.white)

        }
    }
}

struct FunctionButtonView_Previews: PreviewProvider {
    static var previews: some View {
        FunctionButtonView(width: 150, height: 100, text: "Add expense", image: "plus.circle.fill")
    }
}
