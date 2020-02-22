//
//  AddNewTripView.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 28/01/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//

import CoreData
import SwiftUI

struct AddAccountView: View {
    
    @State private var accountName = ""
    @State private var selectedBaseCurrency = Currencies.gbp
    @State private var showingAddMemberView = false
    @State private var showingImagePicker = false
    @State private var members = [Person]()
    @State private var inputImage: UIImage?
    @State private var showingCameraOrPhotoLibActionSheet = false
    @State private var useCamera = false
    
    var moc: NSManagedObjectContext
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Trip details").font(.body)) {
                    TextField("Account name", text: $accountName)
                    Picker("Base currency", selection: $selectedBaseCurrency) {
                        ForEach(Currencies.allCases, id: \.self) { currency in
                            Text(currency.rawValue)
                        }
                    }
                }
                Section(header: Text("Image").font(.body)) {
                    HStack {
                        if inputImage != nil {
                            Image(uiImage: inputImage!)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        } else {
                            Image(String(selectedBaseCurrency.rawValue.lowercased().prefix(3)))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        
                        Button("Change") {
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
                    }
                }
                Section(header: Text("Members").font(.body)) {
                    Button(action: { self.showingAddMemberView.toggle() }) {
                        HStack {
                            Image(systemName: "person.badge.plus.fill")
                            Text("Add member")
                        }
                    }
                    .sheet(isPresented: $showingAddMemberView) { AddMemberView(moc: self.moc, members: self.$members) }
                    ForEach(members, id: \.wrappedId) { member in
                        PersonListItemView(person: member, showingCheckmark: false)
                    }
                }
            }
            .navigationBarTitle(Text("Add new account"))
            .navigationBarItems(leading:
                Button("Cancel") { self.presentationMode.wrappedValue.dismiss() },
                                trailing:
                Button("Save") { self.saveTrip() }.disabled(self.members.isEmpty || self.accountName.isEmpty)
            )
        }
    }
    
    func saveTrip() {
        guard self.accountName.count != 0 else { return } // white spaces
        guard self.members.count != 0 else { return }
        
        let account = Trip(context: self.moc)
        account.id = UUID()
        account.dateCreated = Date()
        account.name = self.accountName
        
        // Convert to data
        if let inputImage = self.inputImage {
            let imageID = UUID().uuidString
            if let jpegData = inputImage.jpegData(compressionQuality: 1) {
                // Save to device
                FileManager.default.writeData(jpegData, to: imageID)
                account.image = imageID
            }
        }
        
        account.baseCurrency = selectedBaseCurrency.rawValue
        account.currenciesUsed = [selectedBaseCurrency.rawValue]
        
        for member in members {
            member.trip = account
        }
        
        do {
            try self.moc.save()
        } catch {
            print(error.localizedDescription)
        }
        
        self.presentationMode.wrappedValue.dismiss()
    }
    
    
}

struct AddNewTripView_Previews: PreviewProvider {
    static var previews: some View {
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let person1 = Person(context: moc)
        person1.name = "Aidan James"
        person1.id = UUID()
        return AddAccountView(moc: moc)
    }
}
