//
//  AddExpenseView.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 06/01/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//

import CoreData
import SwiftUI

struct AddExpenseView: View {
    
    var moc: NSManagedObjectContext
    @ObservedObject var trip: Trip
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var expenseName = ""
    @State private var transactionAmount = ""
    @State private var selectedTransactionCurrency = Currencies.gbp
    @State private var paidForSelected = 0
    @State private var transactionDate = Date()
    @State private var paidBySelection = 0
    @State private var firstEntry = true
    @State private var useCurrentLocation = true
    @State private var showingImagePicker = false
    @State private var showingCameraOrPhotoLibActionSheet = false
    @State private var useCamera = false
    
    @State private var inputImage: UIImage?
    
    let locationFetcher = LocationFetcher()
    
    var amountAsDouble: Double {
        Double(transactionAmount) ?? 0
    }
    
    
    var amountOwedByBeneficiaries: Double {
        guard paidFor.count > 0 else { return 0 }
        return amountAsDouble / Double(paidFor.count)
    }
    
    var paidFor: [Person] {
        return trip.sortedPeopleArray.filter { $0.isSelected }
    }
    
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Expense description", text: $expenseName)
                TextField("Amount", text: $transactionAmount).keyboardType(.decimalPad)
                DatePicker("Transaction date", selection: $transactionDate, in: ...Date(), displayedComponents: .date)
                Text("Base Currency: \(trip.wrappedBaseCurrency)")
                
                Picker("Trn currency", selection: $selectedTransactionCurrency) {
                    ForEach(Currencies.allCases, id: \.self) { currency in
                        Text(currency.rawValue)
                    }
                }
//                .onAppear(perform: populateLastCurrencyUsed)
                
                Button("Print") {
                    print("Selected currency: \(self.selectedTransactionCurrency)")
                }
                
                Toggle(isOn: $useCurrentLocation) {
                    // Need a check here to make sure we can access location
                    Text("Use current location")
                }
                .onAppear(perform: fetchLocation)
                Button(inputImage == nil ? "Add receipt" : "Replace receipt") {
                    self.showingCameraOrPhotoLibActionSheet.toggle()
                }
                .actionSheet(isPresented: self.$showingCameraOrPhotoLibActionSheet) {
                    ActionSheet(title: Text("Add receipt"), buttons: [
                        .default(Text("Take a photo")) {
                            self.useCamera = true
                            self.showingImagePicker.toggle()
                        },
                        .default(Text("Use photo album")) {
                            self.useCamera = false
                            self.showingImagePicker.toggle()
                        },
                        .cancel()
                    ])
                }
                .sheet(isPresented: $showingImagePicker) {
                    ImagePicker(image: self.$inputImage, useCamera: self.useCamera)
                }
                //                Button("Fetch data") { self.fetchData() }
                
                Section {
                    Picker(selection: $paidBySelection, label: Text("Paid by")) {
                        ForEach(0..<trip.sortedPeopleArray.count) {
                            Text(self.trip.sortedPeopleArray[$0].wrappedName)
                        }
                    }
                }
                
                Section(header: Text("Paid for:")) {
                    List {
                        ForEach(trip.sortedPeopleArray, id: \.id) { person in
                            
                            Button(action: person.toggleIsSelected) {
                                PersonListItemView(person: person, showingCheckmark: true)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .onAppear(perform: everyoneIsBeneficiary)
            }
            .navigationBarTitle("Add transaction")
            .navigationBarItems(
                leading:
                Button("Cancel") { self.presentationMode.wrappedValue.dismiss() },
                trailing:
                Button("Save") { self.saveExpense() }
            )
            
        }
    }
    
    func fetchLocation() {
        self.locationFetcher.start()
        
    }
    
    func everyoneIsBeneficiary() {
        guard firstEntry else { return }
        for person in trip.sortedPeopleArray {
            person.isSelected = true
        }
        firstEntry = false
    }
    
    
    func saveExpense() {
        
        guard !expenseName.isEmpty, !paidFor.isEmpty, amountAsDouble > 0 else { return }
        
        // Create the transaction
        let transaction = Transaction(context: self.moc)
        transaction.id = UUID()
        transaction.title = expenseName
        transaction.baseAmt = amountAsDouble
        transaction.exchangeRate = 0
        transaction.trnAmt = amountAsDouble
        transaction.trip = self.trip
        
        transaction.paidBy = self.trip.sortedPeopleArray[paidBySelection]
        self.trip.sortedPeopleArray[paidBySelection].localBal += amountAsDouble
        
        
        for person in paidFor {
            person.localBal -= amountOwedByBeneficiaries
            transaction.addToPaidFor(person)
        }
        
        if useCurrentLocation {
            if let location = self.locationFetcher.lastKnownLocation {
                transaction.longitude = location.longitude
                transaction.latitude = location.latitude
            }
        }
        
        // I'm doing this so we shouldn't have transactions with the exact same date as it messes with the order display (bit of a hack, but OK)
        if !Calendar.current.isDateInToday(transactionDate) {
            transactionDate = Calendar.current.date(byAdding: .second, value: Int.random(in: 1...1000), to: transactionDate) ?? Date()
        }
        transaction.date = transactionDate
        
        // If we have a receipt image...
        if let inputImage = self.inputImage {
            let imageID = UUID().uuidString
            if let jpegData = inputImage.jpegData(compressionQuality: 1) {
                // Save to device
                FileManager.default.writeData(jpegData, to: imageID)
                transaction.photo = imageID
            }
        }
        
        try? self.moc.save()
        self.presentationMode.wrappedValue.dismiss()
        
    }
    
    func fetchData() {
        NetworkService.shared.fetchData(from: "https://api.exchangeratesapi.io/latest?symbols=USD,GBP") { result in
            switch result {
            case .success(let str):
                print(str)
            case .failure(let error):
                switch error {
                case .badURL:
                    print("Bad URL")
                case .requestFailed:
                    print("Bad URL")
                case .unknown:
                    print("Unknown error")
                }
            }
        }
    }
    
//    func populateLastCurrencyUsed() {
//        if let currency = self.trip.wrappedCurrenciesUsed.first {
//            self.selectedTransactionCurrency = currency
//        }
//    }
}




struct AddExpenseView_Previews: PreviewProvider {
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
        
        return AddExpenseView(moc: moc, trip: trip)
    }
}
