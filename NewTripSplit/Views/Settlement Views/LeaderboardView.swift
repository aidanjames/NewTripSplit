//
//  LeaderboardView.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 23/08/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//

import SwiftUI

struct LeaderboardView: View {
    
    let members: [Person]
    
    var min: Double { members.map{$0.localBal}.min() ?? 0 }
    var max: Double { members.map{$0.localBal}.max() ?? 0 }
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("")) {
                    ForEach(members, id: \.self) {
                        LeaderboardRecordView(name: $0.wrappedName, amount: $0.displayLocalBalWithSign, balancePosition: BalancePosition.forPerson($0))
                    }
                }
            }
            .navigationBarTitle(Text("Leaderboard"))
            .navigationBarItems(trailing: Button("Done") { presentationMode.wrappedValue.dismiss() })
        }
        .accentColor(.green)
    }
}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView(members: [])
    }
}

