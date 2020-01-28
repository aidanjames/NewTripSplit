//
//  AddPersonView.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 10/01/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//

import CoreData
import SwiftUI

struct AddPersonView: View {
    
    var moc: NSManagedObjectContext
    
    @Binding var personName: String
    @Binding var personImage: String
    @Binding var people: [Person]
    
    let width = UIScreen.main.bounds.width
        
    var body: some View {
            
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        TextField("Participant name", text: self.$personName)
                            .padding(10)
                        Button(action: {
                            self.addPerson()
                        }) {
                            Image(systemName: "person.badge.plus.fill")
                                .font(.title)
                                .padding(.trailing)
                        }
                        
                    }
                    Rectangle()
                        .frame(height: 1)
                }
                .padding()
                Spacer()
                ZStack {
                    Image(self.personImage)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .background(Color.secondary)
                        .clipShape(Circle())
                    Button(action: { print("Edit photo TBC...\(self.width)") }) {
                        Image(systemName: "pencil.circle.fill")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .offset(x: -20, y: 20)
                }
                .padding(.trailing)
            }
            
            
            

    }
    
    func addPerson() {
        guard !personName.isEmpty else { return }
        let newPerson = Person(context: self.moc)
        newPerson.id = UUID()
        newPerson.name = self.personName
        newPerson.isSelected = true
        self.people.append(newPerson)
        self.personName = ""
        self.personImage = "unknown"
    }
}

struct AddPersonView_Previews: PreviewProvider {
    static var previews: some View {
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        return AddPersonView(moc: moc, personName: .constant(""), personImage: .constant("person3"), people: .constant([Person]()))
            .previewLayout(.sizeThatFits)
    }
}
