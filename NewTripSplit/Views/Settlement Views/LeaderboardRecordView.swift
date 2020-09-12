//
//  LeaderboardRecordView.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 12/09/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//

import SwiftUI

struct LeaderboardRecordView: View {
    
    var name: String
    var amount: String
    var balancePosition: BalancePosition
    
    var body: some View {
        HStack {
            Text("\(name):")
            Spacer()
            Text(amount)
        }
        .foregroundColor(balancePosition == .allSquare ? .secondary : balancePosition == .owes ? .red : .green)
    }
}

struct LeaderboardRecordView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardRecordView(name: "Jason", amount: "-27.34", balancePosition: .owes)
    }
}
