//
//  PersonView.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 04/01/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//

import SwiftUI

struct PersonCardView: View {
    
    @ObservedObject var person: Person
    
    var body: some View {
        
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(Color(.secondarySystemBackground))
                .shadow(radius: 5, x: 4, y: 4)
            VStack(spacing: 8) {
                ZStack {
                    person.wrappedMemberImage
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 75, height: 75)
                        .clipShape(Circle())
                }
                Text(person.wrappedName)
                    .font(.footnote)
                Text("\(person.localBal < -0.099 ? "Owes \(person.displayLocalBal)" : person.localBal > 0.099 ? "Owed \(person.displayLocalBal)" : "All square")")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(5)
                    .background(person.localBal < -0.099 ? Color.red : person.localBal > 0.099 ? Color.green : Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .opacity(50)
            }
        }
        .frame(width: 150, height: 150)
        .overlay(RoundedRectangle(cornerRadius: 20) .stroke(Color.gray, lineWidth: 1))
        .padding(.leading, 15)
        
    }
}

struct PersonView_Previews: PreviewProvider {
    static var previews: some View {
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let person = Person(context: moc)
        person.id = UUID()
        person.name = "Jason Bale"
        person.photo = "person1"
        return PersonCardView(person: person)
            .previewLayout(.sizeThatFits)
    }
}

