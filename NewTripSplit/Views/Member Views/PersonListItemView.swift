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
    
    var displayFaded: Bool { showingCheckmark && !person.isSelected }
    
    var body: some View {
        HStack {
            person.wrappedMemberImage
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .opacity(displayFaded ? 0.5 : 1)
            Text(person.wrappedName)
                .foregroundColor(displayFaded ? .secondary : .primary)
            Spacer()
            if showingCheckmark {
                Image(systemName: person.isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title)
                    .foregroundColor(person.isSelected ? .green : .gray)
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
