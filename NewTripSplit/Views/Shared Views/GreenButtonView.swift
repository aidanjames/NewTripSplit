//
//  GreenButtonView.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 03/03/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//

import SwiftUI

struct GreenButtonView: View {
    
    var text: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack{
                Spacer()
                Text(text)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                Spacer()
            }
            .padding()
            .foregroundColor(Color.white)
            .background(Color.green)
            .cornerRadius(8)
            .padding(.horizontal)
        }
    }
}

struct GreenButtonView_Previews: PreviewProvider {
    static var previews: some View {
        let text = "Create account"
        return GreenButtonView(text: text) { }
    }
}
