//
//  AddTripView.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 06/01/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//

import CoreData
import SwiftUI

struct AddTripView: View {
    
    var moc: NSManagedObjectContext
    @Environment(\.presentationMode) var presentationMode
    
    @State private var tripName = ""
    @State private var tripImage = "trip"
    @State private var personName = ""
    @State private var personImage = "unknown"
    @State private var people = [Person]()
    //    @State private var showingAddPerson = true
    
    let width = UIScreen.main.bounds.width
    
    var peopleString: [String] {
        var returnValue = [String]()
        for person in people {
            returnValue.append(person.firstName)
        }
        return returnValue
    }
    
    
    var body: some View {
        
        NavigationView {
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        TextField("Account name", text: self.$tripName)
                            .padding(10)
                        Rectangle()
                            .frame(height: 1)
                    }
                    .padding()
                    Spacer()
                    ZStack {
                        Image(self.tripImage)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                        Button(action: { print("Edit photo TBC... \(self.width)") }) {
                            Image(systemName: "pencil.circle.fill")
                        }
                        .buttonStyle(PlainButtonStyle())
                        .offset(x: -20, y: 20)
                    }
                    .padding(.trailing)
                }
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("\(self.people.count) participants")
                            .fontWeight(.bold)
                            .padding(10)
                        
                        
                        Spacer()
                        
                        
                    }
                    AddPersonView(moc: self.moc, personName: self.$personName, personImage: self.$personImage, people: self.$people)
                    if !self.people.isEmpty {
                        Text(ListFormatter.localizedString(byJoining: self.peopleString))
                            .font(.footnote)
                            .padding(.horizontal, 10)
                    }
                    
                }
                
                VStack(spacing: 30) {
                    Button(action: { self.saveTrip() }) {
                        FunctionButtonView(width: self.width * 0.8, height: 50, text: "Add account", image: nil)
                    }
                    
                    
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Cancel").fontWeight(.bold)
                            .foregroundColor(.primary)
                            .frame(width: self.width * 0.8, height: 50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.primary, lineWidth: 1)
                        )
                    }
                }
                
                Spacer()
                
                
            }
            .navigationBarTitle("Create account")
        }
        
        
    }
    
    
    
    func saveTrip() {
        guard self.tripName.count != 0 else { return } // white spaces
        guard self.people.count != 0 else { return }
        
        let trip = Trip(context: self.moc)
        trip.id = UUID()
        trip.dateCreated = Date()
        trip.image = self.tripImage
        trip.name = self.tripName
        
        trip.baseCurrency = Currencies.gbp.rawValue
        
        for person in people {
            person.trip = trip
        }
        
        do {
            try self.moc.save()
        } catch {
            print(error.localizedDescription)
        }
        
        
        self.presentationMode.wrappedValue.dismiss()
    }
    
}

struct AddTripView_Previews: PreviewProvider {
    static var previews: some View {
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        return AddTripView(moc: moc)
    }
}
