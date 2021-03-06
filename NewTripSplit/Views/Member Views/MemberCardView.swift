//
//  MemberCardView.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 31/01/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//

import SwiftUI

struct MemberCardView: View {
    
    @ObservedObject var person: Person
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.green, lineWidth: 1)
                .foregroundColor(Color(.secondarySystemBackground))
                .shadow(color: Color("shadow").opacity(colorScheme == .dark ? 0 : 1), radius: 5, x: 5, y: 5)
            VStack(spacing: 8) {
                person.wrappedMemberImage
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 75, height: 75)
                    .clipShape(Circle())
                Text(person.wrappedName)
                    .font(.footnote)
                HStack {
                    Text(person.displayLocalBal)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(5)
                        .background(BalancePosition.forPerson(person) == .owes ? Color.red : BalancePosition.forPerson(person) == .owed ? Color.green : Color.secondary)
                        
                        
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                }
            }
        }
        .frame(width: 150, height: 150)
        .padding(.leading, 15)
        
    }
}

struct MemberCardView_Previews: PreviewProvider {
    static var previews: some View {
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let person = Person(context: moc)
        person.id = UUID()
        person.name = "Jason Bale"
        person.photo = "person1"
        return MemberCardView(person: person)
    }
}
