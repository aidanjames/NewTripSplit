//
//  NewOddsView.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 15/01/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//

import SwiftUI

struct NewOddsView: View {
    
    var trip: Trip
    
    @State private var selectedPerson = 0
    @State private var oddsOffered: String = ""
    @State private var maxPot: String = ""
    @State private var condition: String = ""
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var betting: Betting
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker(selection: $selectedPerson, label: Text("Offered by")) {
                        ForEach(0..<trip.sortedPeopleArray.count) {
                            Text(self.trip.sortedPeopleArray[$0].wrappedName)
                        }
                    }
                }
                
                Section(header: Text("This bet will pay out if...")) {
                    TextField("Condition", text: $condition)
                }
                
                Section(header: Text("Odds offered")) {
                    TextField("Amount (decimal)", text: $oddsOffered).keyboardType(.decimalPad)
                    Text("Fractional: \(Odds.fractionalOddsFrom(double: Double(oddsOffered) ?? 0))")
                }
                
                Section(header: Text("Max pot")) {
                    TextField("Amount prepared to lose", text: $maxPot).keyboardType(.decimalPad)
                }
                
            }
            .navigationBarTitle("New odds")
            .navigationBarItems(
                leading: Button("Cancel") { self.presentationMode.wrappedValue.dismiss() },
                trailing:
                Button("Save") { self.saveOdds() }
            )
        }
        .accentColor(.green)
    }
    
    func saveOdds() {
        guard let amount = Double(oddsOffered) else { return } // add validation
        guard let maxPot = Double(maxPot) else { return } // add validation

        let newOdds = Odds(tripId: self.trip.wrappedId, offeredById: self.trip.sortedPeopleArray[selectedPerson].wrappedId, condition: self.condition, odds: amount, maxPot: maxPot)

        self.betting.add(newOdds)
        self.presentationMode.wrappedValue.dismiss()
    }
}

struct NewOddsView_Previews: PreviewProvider {
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
        return NewOddsView(trip: trip)
    }
}
