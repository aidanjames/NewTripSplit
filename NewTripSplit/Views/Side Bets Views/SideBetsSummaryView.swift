//
//  SideBetsSummaryView.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 15/01/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//

import SwiftUI

struct SideBetsSummaryView: View {
    
    @Environment(\.managedObjectContext) var moc
    
    var trip: Trip
    @State private var showingAddOdds = false
    @State private var showingError = false
    @ObservedObject var betting = Betting()
    
    var filteredOdds: [Odds] {
        return betting.allBets.filter { $0.tripId == trip.wrappedId }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                GreenButtonView(text: "Add odds") { presentAddOddsSheet() }
                    .sheet(isPresented: $showingAddOdds) {
                        NewOddsView(trip: trip).environmentObject(betting)
                }
                if filteredOdds.isEmpty {
                    Text("No bets ☹️")
                }
                ForEach(filteredOdds) { odds in
                    BetCardView(trip: trip, betOffer: odds, moc: moc).environmentObject(betting)
                }
                .navigationBarTitle("Side Bets")
            }
            .alert(isPresented: $showingError) {
                Alert(title: Text("Opps!"), message: Text("You can't add any odds as there are not enough members for the account \(trip.wrappedName)"), dismissButton: .cancel())
            }
        }
        .accentColor(.green)
        .environmentObject(betting)
    }
    
    func presentAddOddsSheet() {
        guard trip.sortedPeopleArray.count > 1 else {
            showingError.toggle()
            return
        }
        showingAddOdds.toggle()
    }
    
}

struct SideBetsSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let trip = Trip(context: moc)
        trip.id = UUID()
        trip.name = "Holiday"
        trip.baseCurrency = Currencies.gbp.rawValue
        trip.currenciesUsed?.append(Currencies.gbp.rawValue)
        trip.dateCreated = Date()
        trip.image = "trip"
        let person1 = Person(context: moc)
        person1.id = UUID()
        person1.name = "John"
        let person2 = Person(context: moc)
        person2.id = UUID()
        person2.name = "John"
        trip.addToPeople(person1)
        trip.addToPeople(person2)
        return SideBetsSummaryView(trip: trip)
    }
}

