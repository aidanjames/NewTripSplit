//
//  SettlementView.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 05/02/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//

import CoreData
import SwiftUI

struct SettlementView: View {
    
    var moc: NSManagedObjectContext
    var account: Trip
    
    @State private var whoPaysWhoArray = [String]()
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("")) {
                    ForEach(whoPaysWhoArray, id: \.self) { record in
                        Text(record)
                    }
                }
            }
            .onAppear { whoPaysWhoArray = account.calculateSettlement() }
            .navigationBarTitle(Text("Settlement"))
            .navigationBarItems(trailing: Button("Done") { presentationMode.wrappedValue.dismiss() })
        }
        .accentColor(.green)
    }
    
}

struct SettlementView_Previews: PreviewProvider {
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
        
        return SettlementView(moc: moc, account: trip)
    }
}
