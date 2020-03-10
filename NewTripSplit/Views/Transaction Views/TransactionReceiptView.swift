//
//  TransactionReceiptView.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 03/02/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//

import SwiftUI

struct TransactionReceiptView: View {
    
    var transaction: Transaction
    @State private var image: Image?
    
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                VStack {
                    if self.image != nil {
                        self.image!
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: geo.size.width)
                    } else {
                        Text("No image")
                    }
                }
                .navigationBarTitle("Reciept view", displayMode: .inline)
                .onAppear(perform: self.loadImage)
            }
        }
    }
    
    func loadImage() {
        if let imageName = transaction.photo {
            if let imageData: Data = FileManager.default.fetchData(from: imageName) {
                if let uiImage = UIImage(data: imageData) {
                    self.image = Image(uiImage: uiImage)
                }
            }
        }
    }
}

struct TransactionReceiptView_Previews: PreviewProvider {
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
        
        let transaction = Transaction(context: moc)
        transaction.id = UUID()
        transaction.title = "Chips"
        transaction.baseAmt = 24.34
        transaction.exchangeRate = 0
        transaction.trnAmt = 24.34
        transaction.date = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        transaction.trip = trip
        transaction.paidBy = person
        transaction.addToPaidFor(person1)
        transaction.latitude = 51.413423
        transaction.longitude = -0.177426
        
        return TransactionReceiptView(transaction: transaction)
    }
}
