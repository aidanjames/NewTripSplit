//
//  BetCardView.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 15/01/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//

import CoreData
import SwiftUI

struct BetCardView: View {
    
    var trip: Trip
    var betOffer: Odds
    var moc: NSManagedObjectContext
    
    @State private var showingAddBetView = false
    @State private var showSettlement: Bool = false
    @State private var xFlipAmount = 0.0
    @State private var yFlipAmount = 0.0
    
    var settleButtonIsDisabled: Bool {
        return betOffer.wagers.isEmpty
    }
    
    @EnvironmentObject var betting: Betting
    
    var offeredBy: Person? {
        return trip.sortedPeopleArray.filter { $0.wrappedId == betOffer.offeredById }.first
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            Text("\(betOffer.betStatus.rawValue)")
                .foregroundColor(betOffer.betStatus == BetStatus.active ? .green : .gray)
                .fontWeight(.bold)
            
            Group {
                Text("\(offeredBy?.firstName ?? "Unknown")")
                    .fontWeight(.bold)
                    + Text(" offers ")
                    + Text(Currencies.format(amount: betOffer.odds))
                        .fontWeight(.bold)
                    + Text(" (\(betOffer.fractionalOdds)) if ")
                    + Text(betOffer.condition)
                        .fontWeight(.bold)
            }
            
            Text("Maximum pot - ")
                + Text(Currencies.format(amount: betOffer.maxPot))
                    .fontWeight(.bold)
            
            if betOffer.wagers.isEmpty {
                Text("No one has placed a bet on these odds.")
                    .foregroundColor(.secondary)
            } else {
                HStack {
                    VStack(alignment: .leading) {
                        ForEach(betOffer.wagers) { wager in
                            Text("\(self.trip.sortedPeopleArray.first(where: { $0.id == wager.wagedById })?.firstName ?? "Unknown") has bet \(Currencies.format(amount: wager.amountWaged)) (pays \(Currencies.format(amount: wager.paysAmount)))")
                            
                        }
                    }
                    Spacer()
                }
                .padding()
                .foregroundColor(.white)
                .font(.footnote)
                .background(betOffer.betStatus == BetStatus.active ? Color.green : Color.secondary)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                
            }
            if betOffer.betStatus == BetStatus.active {
                HStack(spacing: 30) {
                    Spacer()
                    Button(action: self.showSettleView) {
                        Text("Settle")
                    }
                    .disabled(settleButtonIsDisabled)
                    .actionSheet(isPresented: $showSettlement) {
                        ActionSheet(title: Text("Settle bet"), buttons: [
                            .default(Text("Bet won")) { self.betWon(id: self.betOffer.id) },
                            .default(Text("Bet lost")) { self.betLost(id: self.betOffer.id) },
                            .default(Text("Remove bet")) { self.betCancelled(id: self.betOffer.id) },
                            .cancel()
                        ])
                    }
                    
                    Spacer()
                    
                    Button(action: self.showAddBetView) {
                        Text("Add bet")
                    }
                    .sheet(isPresented: $showingAddBetView) { PlaceBetView(trip: self.trip, betOffer: self.betOffer).environmentObject(self.betting)
                    }
                    Spacer()
                }
            }
            
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 5, x: 4, y: 4)
        .padding(.horizontal)
            .rotation3DEffect(.degrees(self.xFlipAmount), axis: (x: 1, y: 0, z: 0)) // If bet wins
            .rotation3DEffect(.degrees(self.yFlipAmount), axis: (x: 0, y: 1, z: 0)) // If bet loses
        
    }
    
    func showSettleView() {
        self.showSettlement.toggle()
    }
    
    func showAddBetView() {
        self.showingAddBetView.toggle()
    }
    
    
    func betWon(id: UUID) {
        guard !betOffer.wagers.isEmpty else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        if let betIndex = betting.allBets.firstIndex(where: { $0.id == id }) {
            let bet = betting.allBets[betIndex]
            
            betting.allBets[betIndex].betStatus = BetStatus.paid
            betting.update()
            
            if let payerIndex = trip.sortedPeopleArray.firstIndex(where: { $0.wrappedId == bet.offeredById }) {
                let loser = trip.sortedPeopleArray[payerIndex]
                for wager in bet.wagers {
                    if let punterIndex = trip.sortedPeopleArray.firstIndex(where: { $0.wrappedId == wager.wagedById }) {
                        let punter = trip.sortedPeopleArray[punterIndex]
                        let amountWon = wager.paysAmount
                        
                        // Create the Dr transaction
                        let transaction = Transaction(context: self.moc)
                        transaction.id = UUID()
                        transaction.title = "Side bet won"
                        transaction.additionalInfo = "\(punter.firstName) bet \(Currencies.format(amount: wager.amountWaged)) on \"\(bet.condition)\" at odds of \(Currencies.format(amount: wager.odds.odds)) offered by \(loser.firstName)."
                        transaction.baseAmt = amountWon
                        transaction.exchangeRate = 0
                        transaction.trnAmt = wager.paysAmount
                        transaction.trnCurrency = trip.wrappedBaseCurrency
                        transaction.date = Date()
                        transaction.trip = self.trip
                        
                        // In this case the person who 'won' the bet is marked as 'Paid by'. It's a bit of an odd case as they've not paid anything but we need a way to balance the books.
                        transaction.paidBy = punter
                        punter.localBal += amountWon
                        
                        // This also seems a bit backwards but we're finding a way of transferring value without actual money changing hands. This way, if the transaction is reversed the relevant parties will be made whole.
                        transaction.addToPaidFor(loser)
                        loser.localBal -= amountWon
                        
                        try? self.moc.save()
                        
                    }
                }
                withAnimation {
                    self.xFlipAmount = 360
                }
                self.xFlipAmount = 0
                
            }
        }
    }
    
    
    func betLost(id: UUID) {
        guard !betOffer.wagers.isEmpty else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        
        if let betIndex = betting.allBets.firstIndex(where: { $0.id == id }) {
            let bet = betting.allBets[betIndex]
            
            betting.allBets[betIndex].betStatus = BetStatus.notPaid
            betting.update()
            
            if let payerIndex = trip.sortedPeopleArray.firstIndex(where: { $0.wrappedId == bet.offeredById }) {
                let winner = trip.sortedPeopleArray[payerIndex]
                for wager in bet.wagers {
                    if let punterIndex = trip.sortedPeopleArray.firstIndex(where: { $0.wrappedId == wager.wagedById }) {
                        let punter = trip.sortedPeopleArray[punterIndex]
                        
                        // Create the Dr transaction
                        let transaction = Transaction(context: self.moc)
                        transaction.id = UUID()
                        transaction.title = "Side bet lost"
                        transaction.additionalInfo = "\(punter.firstName) bet \(Currencies.format(amount: wager.amountWaged)) on \"\(bet.condition)\" at odds of \(Currencies.format(amount: wager.odds.odds)) offered by \(winner.firstName)."
                        transaction.baseAmt = wager.amountWaged
                        transaction.exchangeRate = 0
                        transaction.trnAmt = wager.amountWaged
                        transaction.trnCurrency = trip.wrappedBaseCurrency
                        transaction.date = Date()
                        transaction.trip = self.trip
                        
                        // See notes in betWon()... it's a bit backwards but makes sense if you think about it.
                        transaction.paidBy = winner
                        winner.localBal += wager.amountWaged
                        
                        // Also a bit strange. But works.
                        transaction.addToPaidFor(punter)
                        punter.localBal -= wager.amountWaged
                        
                        try? self.moc.save()
                        
                    }
                }
                withAnimation {
                    self.yFlipAmount = 360
                }
                self.yFlipAmount = 0
            }
        }
        
    }
    
    func betCancelled(id: UUID) {
        // Just delete for now. Will do something more appropriate when I can.
        if let index = betting.allBets.firstIndex(where: { $0.id == id }) {
            betting.allBets.remove(at: index)
        }
        betting.update()
    }
    
}

struct BetCardView_Previews: PreviewProvider {
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
        var bet = Odds(tripId: trip.wrappedId, offeredById: trip.sortedPeopleArray[0].wrappedId, condition: "Aidan beats Sam - Head to head.", odds: 1.34, maxPot: 100.00)
        let wager = Wager(wagedById: person1.id!, amountWaged: 1.00, odds: bet)
        let wager2 = Wager(wagedById: person1.id!, amountWaged: 2.00, odds: bet)
        bet.wagers.append(wager)
        bet.wagers.append(wager2)
        bet.wagers.append(wager2)
        bet.wagers.append(wager2)
        bet.wagers.append(wager2)
        
        return BetCardView(trip: trip, betOffer: bet, moc: moc)
            .previewLayout(.sizeThatFits)
    }
}
