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
    @State private var showingShareSheet = false
    @State private var selectedMember: Person?
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        GeometryReader { geo in
            ZStack {
                Color(hex: "EFEEEE")
                VStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 7) {
                            ForEach(self.trip.sortedPeopleArray, id: \.id) { person in
                                Button(action: {
                                    self.showingMemberSummaryView.toggle()
                                    self.selectedMember = person
                                }) {
                                    MemberCardView(person: person)
                                        .padding(.vertical)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .sheet(isPresented: self.$showingMemberSummaryView) {
                                    MemberDetailView(member: self.selectedMember ?? person, account: self.trip, moc: self.moc)
                                }
                            }
                        }
                    }
                    
                    HStack {
                        Button(action: { self.showingAddExpenseView.toggle() }) {
                            NeumorphicButton(width: 150, height: 80, belowButtonText: "Transaction", onButtonImage: "plus")
                        }
                        .sheet(isPresented: self.$showingAddExpenseView) {
                            AddExpenseView(moc: self.moc, trip: self.trip)
                        }
                        NavigationLink(destination: SideBetsSummaryView(trip: self.trip)) {
//                            NeumorphicButton(width: 150, height: 80, belowButtonText: "Side bets", onButtonImage: "hand.raised")
                            NeumorphicButton(width: 150, height: 80, belowButtonText: "Side bets", image: Image("cardsLARGE"))
                        }
//                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.top, 20)
                    HStack {
                        Button(action: { self.showingSettlementView.toggle() }) {
                            NeumorphicButton(width: 150, height: 80, belowButtonText: "Settlement", onButtonImage: "equal")
                        }
                        .sheet(isPresented: self.$showingSettlementView) {
                            SettlementView(moc: self.moc, account: self.trip)
                        }
                        Button(action: {
                            if self.trip.sortedPeopleArray.count >= 50 {
                               self.showingTooManyMembersWarning.toggle()
                            } else {
                                self.showingAddMemberView.toggle()
                            }
                        }) {
                            NeumorphicButton(width: 150, height: 80, belowButtonText: "Add member", onButtonImage: "person.badge.plus")
                        }
                        .alert(isPresented: self.$showingTooManyMembersWarning) {
                                Alert(title: Text("Waooooh!"), message: Text("Looks like you're a risk taker. You're about to exceed the maximum recommended number of members for an account! Our testing demonstrates that things work best where the number of members is less than 50. If you want to add more, go ahead, but know that you might get some unexpected behaviour."), primaryButton: .destructive(Text("Live dangerously"), action: { self.showingAddMemberView.toggle() }), secondaryButton: .cancel())
                            }
                        .sheet(isPresented: self.$showingAddMemberView) {
                            AddMemberToTripView(moc: self.moc, account: self.trip)
                        }
                    }
//                    Button(action: {
//                        self.createMockData()
//                    }) {
//                        GreenButtonView(text: "Generate mock data")
//                    }
//                    .padding()
                    Spacer()
                }
                TransactionListView(bottomSheetIsOpen: self.$bottomSheetIsOpen, geoSize: geo.size, moc: self.moc, trip: self.trip)
                    .shadow(radius: 5)
            }
            .navigationBarTitle("\(self.trip.wrappedName)", displayMode: .inline)
            .navigationBarItems(trailing:
                
                
                HStack {
                    Button(action: { self.showingShareSheet.toggle() }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title)
                    }
                    .sheet(isPresented: self.$showingShareSheet) { ShareSheet(activityItems: self.itemsForShareSheet()) }
                    .padding()
                    Button(action: { self.showingEditAccountSheet.toggle() }) {
                        Image(systemName: "ellipsis.circle")
                            .font(.title)
                    }
                    .sheet(isPresented: self.$showingEditAccountSheet) { EditAccountView(moc: self.moc, account: self.trip) }
                }
                
            )
        }
        
        
    }
    
    // DELETE THIS
    func createMockData() {
        for i in 1...50 {
            let newPerson = Person(context: self.moc)
            newPerson.name = "David Mills\(i)"
            newPerson.id = UUID()
            newPerson.trip = self.trip
        }
        if self.moc.hasChanges { try? self.moc.save() }
    }
    

    func itemsForShareSheet() -> [String] {
        var array = [String]()
        array.append("*****\(trip.wrappedName.uppercased())*****")
        array.append("\n\n***MEMBER BALANCES***")
        for member in trip.sortedPeopleArray {
            array.append("\(member.wrappedName): \(Currencies.format(currency: trip.wrappedBaseCurrency, amount: member.localBal, withSymbol: true, withSign: true))")
        }
        array.append("\n\n***SETTLEMENT***")
        for settlementRecord in trip.calculateSettlement() {
            array.append(settlementRecord)
        }
        array.append("\n\n***TRANSACTIONS***")
        for transaction in trip.transactionsArray {
            array.append("\(transaction.dateDisplay) \(transaction.wrappedTitle): \(Currencies.format(currency: trip.wrappedBaseCurrency, amount: transaction.baseAmt, withSymbol: true, withSign: false)) \(trip.baseCurrency != transaction.trnCurrency ? "(\(Currencies.format(currency: transaction.trnCurrency ?? "Unknown", amount: transaction.trnAmt, withSymbol: true, withSign: true)) @\(String(format: "%.06f", transaction.exchangeRate)))" : "")\nPaid by \(transaction.paidBy?.wrappedName ?? "") for \(transaction.populatePaidForNames()).\n------------")
        }
        
        return array
    }
    
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
