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
    
    var body: some View {
        
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(Color(.secondarySystemBackground))
                .shadow(color: Color(hex: "D1CDC7"), radius: 5, x: 5, y: 5)
            VStack(spacing: 8) {
                ZStack {
                    person.wrappedMemberImage
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 75, height: 75)
                        .clipShape(Circle())
                }
                Text(person.wrappedName)
                    .foregroundColor(.black)
                    .font(.footnote)
                Text("\(person.localBal < -0.0099 ? "Owes \(person.displayLocalBal)" : person.localBal > 0.0099 ? "Owed \(person.displayLocalBal)" : "All square")")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(5)
                    .background(person.localBal < -0.0099 ? Color.red : person.localBal > 0.0099 ? Color.green : Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .opacity(50)
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
//            .previewLayout(.sizeThatFits)
    }
}
