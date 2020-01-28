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
    @State private var showingAddExpenseSheet = false
    @Environment(\.managedObjectContext) var moc
    
    
    var body: some View {
        
        GeometryReader { geo in
            ZStack {
                VStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(self.trip.sortedPeopleArray, id: \.id) { person in
                                Button(action: { self.printInfoAboutPerson(person: person) }) {
                                    PersonCardView(person: person)
                                        .padding(.vertical)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            Button(action: {}) {
                                VStack {
                                    Image(systemName: "person.crop.circle.badge.plus")
                                        .font(.largeTitle)
                                    Text("Add person")
                                }
                                .foregroundColor(.blue)
                                .padding(.trailing)
                            }
                            .padding()
                        }
                    }
                    VStack(spacing: 15) {
                        Button(action: { self.showingAddExpenseSheet.toggle() }) {
                            FunctionButtonView(width: 250, height: 80, text: "Add expense", image: "plus.circle.fill")
                        }
                        Button(action: {print("Need to show settlement page.")}) {
                            FunctionButtonView(width: 250, height: 80, text: "Settlement", image: "sterlingsign.circle.fill")
                        }
                        NavigationLink(destination: SideBetsSummaryView(trip: self.trip)) {
                            FunctionButtonView(width: 250, height: 80, text: "Side bets", image: "centsign.circle.fill")
                        }
                    }
                    Spacer()
                }
                TransactionListView(bottomSheetIsOpen: self.$bottomSheetIsOpen, geoSize: geo.size, moc: self.moc, trip: self.trip)
                    .shadow(radius: 5)
            }
            .navigationBarTitle("\(self.trip.wrappedName)", displayMode: .inline)
            .sheet(isPresented: self.$showingAddExpenseSheet) {
                AddExpenseView(moc: self.moc, trip: self.trip)
            }
        }
    }
    
    func printInfoAboutPerson(person: Person) {
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
