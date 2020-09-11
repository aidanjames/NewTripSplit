//
//  AddExpenseView.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 06/01/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//

import CoreData
import CoreLocation
import SwiftUI

struct AddExpenseView: View {
    
    var moc: NSManagedObjectContext
    @ObservedObject var trip: Trip
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var currencyPair = CurrencyPair.shared
    
    @State private var expenseName = ""
    @State private var transactionAmount = ""
    @State private var selectedTransactionCurrency = Currencies.gbp
    @State private var firstEntry = true
    @State private var transactionDate = Date()
    @State private var paidBySelection = 0
    @State private var useCurrentLocation = true
    @State private var showingImagePicker = false
    @State private var showingCameraOrPhotoLibActionSheet = false
    @State private var useCamera = false
    
    @State private var inputImage: UIImage?
    
    @State private var showingRateError = false
    @State private var showingManualRateInputField = false
    @State private var manualExchangeRate = ""
    var manualExchRateButtonDisabled: Bool { Double(manualExchangeRate) == nil }
    
    // Confirm paid by...
    @State private var showingPaidByConfirmationAlert = false
    @State private var paidByConfirmed = false
    
    
    @ObservedObject var locationFetcher = LocationFetcher.shared
    
    var baseTransactionAmount: Double {
        if let trnAmount = Double(transactionAmount) {
            guard trip.baseCurrency != selectedTransactionCurrency.rawValue else { return trnAmount }
            if currencyPair.exchangeRate > 0 {
                return (Double(transactionAmount) ?? 0) / currencyPair.exchangeRate
            } else {
                return 0
            }
        }
        return 0
    }
    
    var amountOwedByBeneficiaries: Double {
        guard paidFor.count > 0 else { return 0 }
        return baseTransactionAmount / Double(paidFor.count)
    }
    
    var paidFor: [Person] {
        return trip.sortedPeopleArray.filter { $0.isSelected }
    }
    
    var saveButtonDisabled: Bool {
        ((trip.baseCurrency != selectedTransactionCurrency.rawValue) && currencyPair.exchangeRate == 0) || baseTransactionAmount == 0 || expenseName.isEmpty
    }
    
    var body: some View {
        NavigationView {
            Form {
                Group {
                    TextField("Transaction description", text: $expenseName)
                    HStack {
                        Text("\(Currencies.symbol(for: selectedTransactionCurrency.rawValue))")
                        TextField("Transaction amount", text: $transactionAmount).keyboardType(.decimalPad)
                    }
                    Picker("Currency", selection: $selectedTransactionCurrency) {
                        ForEach(Currencies.allCases, id: \.self) { currency in
                            Text(currency.rawValue)
                        }
                    }
                    .onAppear(perform: setExchangeRate)
                    if trip.baseCurrency != selectedTransactionCurrency.rawValue && currencyPair.error == nil {
                        Text("Base amount \(Currencies.format(currency: trip.wrappedBaseCurrency, amount: baseTransactionAmount, withSymbol: true, withSign: true)) (rate: \(currencyPair.exchangeRate))")
                    }
                    if currencyPair.error != nil && !showingManualRateInputField {
                        Text("Cannot fetch exchange rate")
                            .foregroundColor(.red)
                            .onAppear(perform: showError)
                            .actionSheet(isPresented: $showingRateError) {
                                ActionSheet(title: Text("Failed to get exchange rate"), buttons: [
                                    .default(Text("Try again")) { setExchangeRate() },
                                    .default(Text("Enter rate manually")) { showingManualRateInputField = true },
                                    .cancel()
                                ])
                            }
                    }
                    if showingManualRateInputField {
                        HStack {
                            TextField("Enter exchange rate", text: $manualExchangeRate).keyboardType(.decimalPad)
                            Button("Apply") {
                                currencyPair.manuallySetExchangeRate(manualExchangeRate)
                                showingManualRateInputField = false
                                manualExchangeRate = ""
                            }.disabled(manualExchRateButtonDisabled)
                        }
                    }
                    DatePicker("Date", selection: $transactionDate, in: ...Date(), displayedComponents: .date)
                    if locationFetcher.hasPermission { // Only show if we have permission to use location
                        Toggle(isOn: $useCurrentLocation) {
                            Text("Use current location")
                        }
                    }
                    Button(inputImage == nil ? "Add receipt" : "Replace receipt") {
                        showingCameraOrPhotoLibActionSheet.toggle()
                    }
                    .actionSheet(isPresented: $showingCameraOrPhotoLibActionSheet) {
                        ActionSheet(title: Text("Add receipt"), buttons: [
                            .default(Text("Take a photo")) {
                                useCamera = true
                                showingImagePicker.toggle()
                            },
                            .default(Text("Use photo album")) {
                                useCamera = false
                                showingImagePicker.toggle()
                            },
                            .cancel()
                        ])
                    }
                    .sheet(isPresented: $showingImagePicker) {
                        ImagePicker(image: $inputImage, useCamera: useCamera)
                    }
                }
                Section {
                    Picker(selection: $paidBySelection, label: Text("Paid by")) {
                        ForEach(0..<trip.sortedPeopleArray.count) {
                            Text(trip.sortedPeopleArray[$0].wrappedName)
                        }
                    }
                    .alert(isPresented: $showingPaidByConfirmationAlert) {
                        Alert(title: Text("Confirm transaction"), message: Text("Transaction for \(Currencies.symbol(for: selectedTransactionCurrency.rawValue))\(transactionAmount) was paid by \(trip.sortedPeopleArray[paidBySelection].wrappedName) for \(paidFor.count) \(paidFor.count == 1 ? "person" : "people"). Is this correct?"), primaryButton: .destructive(Text("Confirm"), action: {
                            paidByConfirmed = true
                            showingPaidByConfirmationAlert = false
                            saveExpense()
                        }), secondaryButton: .cancel())
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
                //                .onAppear(perform: everyoneIsBeneficiary)
            }
            .navigationBarTitle("Add transaction")
            .navigationBarItems(
                leading:
                    Button("Cancel") { presentationMode.wrappedValue.dismiss() },
                trailing:
                    Button("Save") {
                        if !paidByConfirmed {
                            showingPaidByConfirmationAlert = true
                        } else {
                            saveExpense()
                        }
                    }
                    .disabled(saveButtonDisabled)
            )
            .onAppear {
                fetchLocation()
                everyoneIsBeneficiary()
            }
            
        }
        .accentColor(.green)
    }
    
    
    func fetchLocation() {
        guard firstEntry else { return } // So we don't re-run this every time the user changes currency
        locationFetcher.start()
    }
    
    
    func showError() {
        showingRateError = true
    }
    
    
    func everyoneIsBeneficiary() {
        guard firstEntry else { return } // So we don't re-run this every time the user changes currency
        for person in trip.sortedPeopleArray {
            person.isSelected = true
        }
        firstEntry = false
    }
    
    
    func saveExpense() {
        
        guard !expenseName.isEmpty, !paidFor.isEmpty, baseTransactionAmount > 0 else { return }
        
        // Create the transaction
        let transaction = Transaction(context: moc)
        transaction.id = UUID()
        transaction.title = expenseName
        transaction.baseAmt = baseTransactionAmount
        transaction.exchangeRate = currencyPair.exchangeRate
        transaction.trnAmt = Double(transactionAmount) ?? 0
        transaction.trip = trip
        transaction.trnCurrency = selectedTransactionCurrency.rawValue
        
        // To allow the transaction currency to be pre-populated with the most recently used currency on the next transaction
        if selectedTransactionCurrency.rawValue != trip.wrappedCurrenciesUsed[0] {
            trip.currenciesUsed?.insert(selectedTransactionCurrency.rawValue, at: 0)
        }
        
        // Increase the balance of the person paying
        transaction.paidBy = trip.sortedPeopleArray[paidBySelection]
        trip.sortedPeopleArray[paidBySelection].localBal += baseTransactionAmount
        
        // Reduce the balance of each beneficiary
        for person in paidFor {
            person.localBal -= amountOwedByBeneficiaries
            transaction.addToPaidFor(person)
        }
        
        // TODO: What if we don't have permission to get location?
        if useCurrentLocation {
            if let location = locationFetcher.lastKnownLocation {
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
        if let inputImage = inputImage {
            let imageID = UUID().uuidString
            if let jpegData = inputImage.jpegData(compressionQuality: 1) {
                // Save data to device
                FileManager.default.writeData(jpegData, to: imageID)
                transaction.photo = imageID
            }
        }
        
        try? moc.save()
        presentationMode.wrappedValue.dismiss()
    }
    
    
    func setExchangeRate() {
        currencyPair.exchangeRate = 0
        currencyPair.error = nil
        
        // This will pre-populate the transaction currency with the most recently used transaction
        if firstEntry { // So we don't reset it every time we return from the currency selection screen
            if let currency = trip.wrappedCurrenciesUsed.first {
                if let currencyObject = Currencies.allCases.first(where: { $0.rawValue == currency }) {
                    selectedTransactionCurrency = currencyObject
                }
            }
        }
        
        guard trip.baseCurrency != selectedTransactionCurrency.rawValue else { return }
        if let baseCurrency = trip.baseCurrency {
            let transactionCurrency = selectedTransactionCurrency.rawValue
            currencyPair.baseCurrency = String(baseCurrency.prefix(3))
            currencyPair.foreignCurrency = String(transactionCurrency.prefix(3))
            currencyPair.getExchangeRate()
        }
    }
    
    
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
