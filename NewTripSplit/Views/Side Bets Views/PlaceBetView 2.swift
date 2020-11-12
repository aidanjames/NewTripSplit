//
//  PlaceBetView.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 15/01/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//

import SwiftUI

struct PlaceBetView: View {
    
    var trip: Trip
    var betOffer: Odds
    @EnvironmentObject var betting: Betting
    
    @State private var selectedBetter = 0
    @State private var betAmount = ""
    
    @Environment(\.presentationMode) var presentationMode
    
    var offeredBy: Person? {
        return trip.sortedPeopleArray.filter { $0.wrappedId == betOffer.offeredById }.first
    }
    
    var potentialPunters: [Person] {
        return trip.sortedPeopleArray.filter { $0.wrappedId != betOffer.offeredById }
    }
    
    var payoutAmount: String {
        var returnValue = Currencies.format(amount: 0)
        if let betAmount = Double(betAmount) {
            let payoutDouble = (betAmount * betOffer.odds) - betAmount
            returnValue = Currencies.format(amount: payoutDouble)
        }
        return returnValue
    }
    
    var subscribedAmount: String {
        var subscribedDouble = 0.0
        for bet in betOffer.wagers {
            subscribedDouble += bet.paysAmount
        }
        if let betAmount = Double(betAmount) {
            subscribedDouble += (betAmount * betOffer.odds) - betAmount
        }
        return Currencies.format(amount: subscribedDouble)
    }
    
    var potExceeded: Bool {
        var subscribedDouble = 0.0
        for bet in betOffer.wagers {
            subscribedDouble += bet.paysAmount
        }
        if let betAmount = Double(betAmount) {
            subscribedDouble += (betAmount * betOffer.odds) - betAmount
        }
        return subscribedDouble > betOffer.maxPot
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Bet details")) {
                    Picker(selection: $selectedBetter, label: Text("Punter")) {
                        ForEach(0..<potentialPunters.count) {
                            Text(potentialPunters[$0].wrappedName)
                        }
                    }
                    TextField("Amount to bet", text: $betAmount).keyboardType(.decimalPad)
                    Text("Payout amount: \(payoutAmount)")
                }
                
                Section(header: Text("Amount subcribed to pot (including this bet)")) {
                    Text("\(subscribedAmount) of \(Currencies.format(amount: betOffer.maxPot))")
                        .foregroundColor(potExceeded ? .red : .primary)
                }
                
                Section(header: Text("Offer details")) {
                    VStack(alignment: .leading) {
                        Text(betOffer.betStatus.rawValue)
                            .foregroundColor(.green)
                            .fontWeight(.bold)
                        Text("\(offeredBy?.firstName ?? "Unknown")")
                            .fontWeight(.bold)
                            + Text(" will pay odds of ")
                            + Text(Currencies.format(amount: betOffer.odds))
                                .fontWeight(.bold)
                            + Text(" per \(Currencies.format(amount: 1.00)) (\(betOffer.fractionalOdds)) if ")
                            + Text(betOffer.condition)
                                .fontWeight(.bold)
                    }
                }

            }
            .navigationBarTitle("Add bet")
            .navigationBarItems(leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() }, trailing: Button("Save bet") { saveBet()}.disabled(potExceeded))
        }
        .accentColor(.green)
//        .onTapGesture { UIApplication.shared.endEditing() }
    }
    
    func saveBet() {
        guard let amount = Double(betAmount) else { return }

        let newBet = Wager(wagedById: potentialPunters[selectedBetter].wrappedId, amountWaged: amount, odds: betOffer)
        
        // Find offer in existing betting.allBets array...
        if let index = betting.allBets.firstIndex(where: { $0.id == betOffer.id }) {
            betting.allBets[index].wagers.append(newBet)
        }
        
        // Save all bets
        betting.update()
        
        presentationMode.wrappedValue.dismiss()
    }
}

struct PlaceBetView_Previews: PreviewProvider {
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
        person1.name = "Johnny"
        let person2 = Person(context: moc)
        person2.id = UUID()
        person2.name = "JohnB"
        trip.addToPeople(person1)
        trip.addToPeople(person2)
        let bet = Odds(tripId: trip.wrappedId, offeredById: trip.sortedPeopleArray[0].wrappedId, condition: "Aidan beats Sam - Head to head.", odds: 1.34, maxPot: 100.00)
        let allBets = Betting()
        
        return PlaceBetView(trip: trip, betOffer: bet).environmentObject(allBets)
    }
}
