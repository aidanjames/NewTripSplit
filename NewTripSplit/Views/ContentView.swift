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
    
    func loadAccountImages() {
        // I need to extract out the list view for each of these and then I can fetch the image data from File manager.
    }
    
    func addTrips() {
        
        // Create people
        let person1 = Person(context: self.moc)
        person1.id = UUID()
        person1.name = "Jason Bale"
        person1.localBal = 0.0
        person1.photo = "person1"
        
        let person2 = Person(context: self.moc)
        person2.id = UUID()
        person2.name = " Sarah Bishop"
        person2.localBal = 0.0
        //        person2.photo = "person2"
        
        let person3 = Person(context: self.moc)
        person3.id = UUID()
        person3.name = "Dale Husband"
        person3.localBal = 0.0
        person3.photo = "person3"
        
        // Create trip
        let trip = Trip(context: self.moc)
        trip.id = UUID()
        trip.image = "trip"
        trip.name = "Marbella golf 2020"
        
        // Create transactions
        let transaction1 = Transaction(context: self.moc)
        transaction1.id = UUID()
        transaction1.baseAmt = 12.45
        transaction1.date = Date()
        transaction1.exchangeRate = 0.0
        transaction1.photo = "receipt"
        transaction1.title = "Dinner"
        transaction1.additionalInfo = "Pizza & Beers."
        transaction1.trnAmt = 12.45
        
        let transaction2 = Transaction(context: self.moc)
        transaction2.id = UUID()
        transaction2.baseAmt = 28.00
        transaction2.date = Date()
        transaction2.exchangeRate = 0.0
        transaction2.photo = "receipt"
        transaction2.title = "Taxi"
        transaction2.additionalInfo = "From my place to the airport."
        transaction2.trnAmt = 20.00
        
        // Assign everything
        trip.baseCurrency = Currencies.gbp.rawValue
        trip.currenciesUsed?.append(Currencies.gbp.rawValue)
        person1.trip = trip
        person1.localBal = 32.45
        person2.trip = trip
        person2.localBal = -16.23
        person3.trip = trip
        person3.localBal = -16.22
        transaction1.paidBy = person1
        transaction1.trnCurrency = Currencies.gbp.rawValue
        transaction1.addToPaidFor(person2)
        transaction1.addToPaidFor(person3)
        transaction1.trip = trip
        transaction2.paidBy = person1
        transaction2.trnCurrency = Currencies.gbp.rawValue
        transaction2.addToPaidFor(person2)
        transaction2.addToPaidFor(person3)
        transaction2.trip = trip
        
        // Save the context
        try? self.moc.save()
        
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
