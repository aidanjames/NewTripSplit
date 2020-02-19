//
//  AccountCardView.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 01/02/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//

import CoreData
import SwiftUI

struct AccountCardView: View {
    
    @Environment(\.managedObjectContext) var moc
    var account: Trip
    
    @State private var showingDeleteWarning = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(Color(hex: "EFEEEE"))
                .shadow(color: Color(hex: "D1CDC7"), radius: 5, x: 5, y: 5)
            HStack(spacing: 8) {
                account.wrappedAccountImage
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding()
                VStack {
                    HStack {
                        Text(account.wrappedName)
                            .foregroundColor(.black)
                            .font(.title)
                        Spacer()
                    }
                    HStack {
                        Button(action: { self.showingDeleteWarning.toggle() }) {
                            NeumorphicButton(width: 80, height: 50, belowButtonText: nil, onButtonText: "Edit", onButtonImage: nil, circleShape: false)
                        }
                        .alert(isPresented: $showingDeleteWarning) {
                            Alert(title: Text("Delete account?"), message: Text("This will delete the account and it won't come back."), primaryButton: .destructive(Text("Delete")) { self.deleteAccount() }, secondaryButton: .cancel())
                        }
                        Spacer()
                        NavigationLink(destination: TripView(trip: self.account)) {
                            NeumorphicButton(width: 120, height: 50, belowButtonText: nil, onButtonText: "View account", onButtonImage: nil, circleShape: false)
                        }
                        Spacer()
                    }
                }
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, minHeight: 150, idealHeight: 150, maxHeight: .infinity)
        .padding(.horizontal)
        .padding(.top, 18)
    }
    
    func deleteAccount() {
        
        for member in account.sortedPeopleArray {
            moc.delete(member)
        }
        
        for transaction in account.transactionsArray {
            moc.delete(transaction)
        }
        
        moc.delete(account)
    }
}

struct AccountCardView_Previews: PreviewProvider {
    static var previews: some View {
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let trip = Trip(context: moc)
        trip.id = UUID()
        trip.name = "Preview trip"
        trip.image = "trip"
        let person = Person(context: moc)
        person.id = UUID()
        person.name = "Dale"
        let person1 = Person(context: moc)
        person1.id = UUID()
        person1.name = "Sharon"
        person1.photo = "person2"
        trip.addToPeople(person)
        trip.addToPeople(person1)
        return AccountCardView(account: trip).environment(\.managedObjectContext, moc)
    }
}
