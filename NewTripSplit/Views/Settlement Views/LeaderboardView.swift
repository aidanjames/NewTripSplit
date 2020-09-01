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
                        Text("\($0.wrappedName): \($0.displayLocalBalWithSign)")
                            .foregroundColor($0.localBal < 0 ? .red : .green)
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
