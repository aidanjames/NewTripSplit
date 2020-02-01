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
    @State private var showingSettlementView = false
    @State private var showingMemberSummaryView = false
    @Environment(\.managedObjectContext) var moc
    
    
    var body: some View {
        
        GeometryReader { geo in
            ZStack {
                Color(hex: "EFEEEE")
                VStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 7) {
                            ForEach(self.trip.sortedPeopleArray, id: \.id) { person in
                                Button(action: { self.printInfoAboutPerson(person: person) }) {
                                    MemberCardView(person: person)
                                        .padding(.vertical)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .sheet(isPresented: self.$showingMemberSummaryView) {
                                    Text("Placeholder for member summary view")
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
                            NeumorphicButton(width: 150, height: 80, belowButtonText: "Side bets", onButtonImage: "hand.raised")
                        }
                    }
                    .padding(.top, 20)
                    HStack {
                        Button(action: { self.showingSettlementView.toggle() }) {
                            NeumorphicButton(width: 150, height: 80, belowButtonText: "Settlement", onButtonImage: "equal")
                        }
                        .sheet(isPresented: self.$showingSettlementView) {
                            Text("Placeholder for settlement view")
                        }
                        Button(action: { self.showingAddMemberView.toggle() }) {
                            NeumorphicButton(width: 150, height: 80, belowButtonText: "Add member", onButtonImage: "person.badge.plus")
                        }
                        .sheet(isPresented: self.$showingAddMemberView) {
                            AddMemberToTripView(moc: self.moc, account: self.trip)
                        }
                    }
                    Spacer()
                }
                TransactionListView(bottomSheetIsOpen: self.$bottomSheetIsOpen, geoSize: geo.size, moc: self.moc, trip: self.trip)
                    .shadow(radius: 5)
            }
            .navigationBarTitle("\(self.trip.wrappedName)", displayMode: .inline)
            
        }
        
    }
    
    func printInfoAboutPerson(person: Person) {
        self.showingMemberSummaryView.toggle()
        print("Person name: \(person.wrappedName)")
        print("Person balance: \(person.localBal)")
        print("Transactions paid for:")
        for transaction in person.payerArray {
            print(transaction.wrappedTitle)
        }
        print("Transactions beneficiary of:")
        for transaction in person.beneficiaryArray {
            print(transaction.wrappedTitle)
        }
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
