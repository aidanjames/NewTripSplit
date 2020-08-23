//
//  LeaderboardView.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 23/08/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//

import SwiftUI

struct LeaderboardView: View {
    
    let members = TempTripObject().members
    
    var min: Double { members.map{$0.balance}.min() ?? 0 }
    var max: Double { members.map{$0.balance}.max() ?? 0 }
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            ForEach(members) {
                Text("\($0.name), bal: \($0.balance)")
            }
        }
    }
}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView()
    }
}

// DELETE THESE TWO STRUCTS WHEN THE SORTED ARRAY IS PLUGGED INTO THE MEMBERS VAR
struct TempMemberObject: Identifiable {
    let id = UUID()
    let name: String
    let balance: Double
}

struct TempTripObject {
    let members: [TempMemberObject]
    
    init() {
        let aidan = TempMemberObject(name: "Aidan", balance: -150.45)
        let john = TempMemberObject(name: "John", balance: -234.11)
        let luke = TempMemberObject(name: "Luke", balance: 23.40)
        let mick = TempMemberObject(name: "Mick Dole", balance: 289.94)
        let sara = TempMemberObject(name: "Sara", balance: 122.20)
        let paul = TempMemberObject(name: "Paul", balance: 179.21)
        
        members = [aidan, john, luke, mick, sara, paul].sorted { $0.balance < $1.balance }
    }
}
