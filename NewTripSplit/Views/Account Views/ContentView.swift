//
//  ContentView.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 03/01/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Trip.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)
    ]) var trips: FetchedResults<Trip>
    
    @State private var showingAddTrip = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                ZStack {
                    VStack {
                        if trips.isEmpty {
                            VStack {
                                Image("cactus")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100)
                            }
                            .padding()
                            .padding(.top)
                            Text("Hmmm there's no accounts yet....")
                                .foregroundColor(.secondary)
                                .padding()
                                .padding(.bottom)
                            GreenButtonView(text: "Create account") { showingAddTrip.toggle() }
                                .padding(.top)
                        } else {
                            VStack {
                                GreenButtonView(text: "Create account") { showingAddTrip.toggle() }
                                    .padding(.top)
                                ForEach(trips, id: \.id) { trip in
                                    NavigationLink(destination: TripView(trip: trip)) {
                                        AccountCardView(account: trip)
                                            .padding(.horizontal, 5)
                                    }.buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        Spacer()
                    }
                }
                .navigationBarTitle("Accounts")
                .sheet(isPresented: $showingAddTrip) { AddAccountView(moc: moc) }
            }
        }
        .accentColor(.green)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let trip = Trip(context: moc)
        trip.id = UUID()
        trip.name = "Preview trip"
        trip.image = "trip"
        return ContentView().environment(\.managedObjectContext, moc)
    }
}


