//
//  PersonListItemView.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 13/01/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//

import SwiftUI

struct PersonListItemView: View {
    
    @ObservedObject var person: Person
    var showingCheckmark: Bool
    
    var body: some View {
        HStack {
            Image(person.wrappedPhoto)
                .resizable()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            Text(person.wrappedName)
            Spacer()
            if showingCheckmark {
                Image(systemName: self.person.isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title)
                    .foregroundColor(self.person.isSelected ? .green : .gray)
            }
        }
    .contentShape(Rectangle())
        .padding(.horizontal)
    }
}

struct PersonListItemView_Previews: PreviewProvider {
    static var previews: some View {
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let person = Person(context: moc)
        person.id = UUID()
        person.name = "Jason Bale"
        person.photo = "person1"
        return Group {
            PersonListItemView(person: person, showingCheckmark: true)
                .previewLayout(.sizeThatFits)
            PersonListItemView(person: person, showingCheckmark: false)
            .previewLayout(.sizeThatFits)
        }
    }
}
