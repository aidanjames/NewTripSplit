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
            VStack {
                List {
                    ForEach(trips, id: \.id) { trip in
                        NavigationLink(destination: TripView(trip: trip)) {
                            HStack {
                                trip.wrappedAccountImage
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                Text(trip.wrappedName)
                            }
                        }
                    }
                }
                .sheet(isPresented: $showingAddTrip) { AddAccountView(moc: self.moc)}
            }
            .navigationBarTitle("Accounts")
            .navigationBarItems(trailing:
                HStack {
                    Button(action: { self.showingAddTrip.toggle() }) {
                        Text("Add account")
                            .padding()
                    }
                }
            )
        }
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
