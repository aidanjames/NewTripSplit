//
//  TripView.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 03/01/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//

import SwiftUI

struct TripView: View {
    
    @ObservedObject var trip: Trip
    
    @State private var bottomSheetIsOpen = false
    @State private var showingAddExpenseView = false
    @State private var showingAddMemberView = false
    @State private var showingTooManyMembersWarning = false
    @State private var showingSettlementView = false
    @State private var showingMemberSummaryView = false
    @State private var showingEditAccountSheet = false
    @State private var showingShareActionSheet = false
    @State private var shareItems: ShareItems = .leaderboard
    @State private var showingShareSheet = false
    @State private var selectedMember: Person?
    @State private var newSelectedMember: UUID = UUID()
    @State private var showingLeaderboard = false
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        GeometryReader { geo in
            ZStack {
                Color("offWhite")
                VStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 7) {
                            ForEach(trip.sortedPeopleArray, id: \.id) { person in
                                
                                MemberCardView(person: person)
                                    .onTapGesture {
                                        selectedMember = person
                                        showingMemberSummaryView.toggle()
                                    }
                                    .padding(.vertical)
                                
                                // There is a weird bug where the selectedMember value is not being populated on the MemberDetailView and we're sending through the first person in the array instead. I cannot for the life of me figure this one out and cannot figure out a workaround either.
                                    .fullScreenCover(isPresented: $showingMemberSummaryView) {
                                        MemberDetailView(member: selectedMember ?? person, account: trip, moc: moc)
                                    }
                            }
                        }
                    }
                    HStack {
                        Button(action: { showingAddExpenseView.toggle() }) {
                            NeumorphicButton(width: 150, height: 80, belowButtonText: "Transaction", onButtonImage: "plus")
                        }
                        .fullScreenCover(isPresented: $showingAddExpenseView) {
                            AddExpenseView(moc: moc, trip: trip)
                        }
                        //                        NavigationLink(destination: SideBetsSummaryView(trip: trip)) {
                        //                            NeumorphicButton(width: 150, height: 80, belowButtonText: "Side bets", image: Image(systemName: "dollarsign.circle.fill"))
                        //                        }
                        Button(action: { showingLeaderboard.toggle() }) {
                            NeumorphicButton(width: 150, height: 80, belowButtonText: "Leaderboard", onButtonImage: "list.number")
                        }
                        .sheet(isPresented: $showingLeaderboard) {
                            LeaderboardView(members: trip.sortedPeopleArray)
                        }
                    }
                    .padding(.top, 20)
                    HStack {
                        Button(action: { showingSettlementView.toggle() }) {
                            NeumorphicButton(width: 150, height: 80, belowButtonText: "Settlement", onButtonImage: "equal")
                        }
                        .sheet(isPresented: $showingSettlementView) {
                            SettlementRecordsView(moc: moc, account: trip)
                        }
                        Button(action: {
                            if trip.sortedPeopleArray.count >= 50 {
                                showingTooManyMembersWarning.toggle()
                            } else {
                                showingAddMemberView.toggle()
                            }
                        }) {
                            NeumorphicButton(width: 150, height: 80, belowButtonText: "Add member", onButtonImage: "person.badge.plus")
                        }
                        .alert(isPresented: $showingTooManyMembersWarning) {
                            Alert(title: Text("Waooooh!"), message: Text("Looks like you're a risk taker. You're about to exceed the maximum recommended number of members for an account! Our testing demonstrates that things work best where the number of members is less than 50. If you want to add more, go ahead, but know that you might get some unexpected behaviour."), primaryButton: .destructive(Text("Live dangerously"), action: { showingAddMemberView.toggle() }), secondaryButton: .cancel())
                        }
                        .fullScreenCover(isPresented: $showingAddMemberView) {
                            AddMemberToTripView(moc: moc, account: trip)
                        }
                    }
                    Spacer()
                }
                TransactionListView(bottomSheetIsOpen: $bottomSheetIsOpen, geoSize: geo.size, moc: moc, trip: trip)
                    .shadow(radius: 5)
            }
            .accentColor(.green)
            .navigationBarTitle("\(trip.wrappedName)", displayMode: .inline)
            .navigationBarItems(trailing:
                                    HStack {
                Button(action: { showingShareActionSheet.toggle() }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title)
                }
                .actionSheet(isPresented: $showingShareActionSheet) {
                    ActionSheet(title: Text("Share trip info"), message: nil, buttons: [
                        .default(Text("Leaderboard")) {
                            shareItems = .leaderboard
                            showingShareSheet.toggle()
                        },
                        .default(Text("Settlement")) {
                            shareItems = .settlement
                            showingShareSheet.toggle()
                        },
                        .default(Text("Transactions")) {
                            shareItems = .transactions
                            showingShareSheet.toggle()
                        },
                        .default(Text("Full bhuna")) {
                            shareItems = .all
                            showingShareSheet.toggle()
                        },
                        .cancel()
                    ])
                }
                .sheet(isPresented: $showingShareSheet) { ShareSheet(activityItems: itemsForShareSheet()) }
                .padding()
                Button(action: { showingEditAccountSheet.toggle() }) {
                    Image(systemName: "ellipsis.circle")
                        .font(.title)
                }
                .sheet(isPresented: $showingEditAccountSheet) { EditAccountView(moc: moc, account: trip) }
            }
                                    .foregroundColor(.green)
                                
            )
        }
        
        
    }
    
    
    func itemsForShareSheet() -> [String] {
        var array = [String]()
        array.append("*****\(trip.wrappedName.uppercased())*****")
        
        if shareItems == .leaderboard || shareItems == .all {
            array.append("\n\n***MEMBER BALANCES***")
            for member in trip.sortedPeopleArray {
                array.append("\(member.wrappedName): \(Currencies.format(currency: trip.wrappedBaseCurrency, amount: member.localBal, withSymbol: true, withSign: true))")
            }
        }
        
        if shareItems == .settlement || shareItems == .all  {
            array.append("\n\n***SETTLEMENT***")
            for settlementRecord in trip.calculateSettlement() {
                array.append(settlementRecord)
            }
        }
        
        if shareItems == .transactions || shareItems == .all  {
            array.append("\n\n***TRANSACTIONS***")
            for transaction in trip.transactionsArray {
                array.append("\(transaction.dateDisplay) \(transaction.wrappedTitle): \(Currencies.format(currency: trip.wrappedBaseCurrency, amount: transaction.baseAmt, withSymbol: true, withSign: false)) \(trip.baseCurrency != transaction.trnCurrency ? "(\(Currencies.format(currency: transaction.trnCurrency ?? "Unknown", amount: transaction.trnAmt, withSymbol: true, withSign: true)) @\(String(format: "%.06f", transaction.exchangeRate)))" : "")\nPaid by \(transaction.paidBy?.wrappedName ?? "") for \(transaction.populatePaidForNames()).\n------------")
            }
        }
        return array
    }
    
}

enum ShareItems {
    case leaderboard, settlement, transactions, all
}

struct TripView_Previews: PreviewProvider {
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
        return TripView(trip: trip).environment(\.managedObjectContext, moc)
    }
}
