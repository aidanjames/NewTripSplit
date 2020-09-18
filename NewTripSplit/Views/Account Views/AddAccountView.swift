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
    @State private var showingTooManyMembersWarning = false
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
                }
                Section(header: Text("Members").font(.body)) {
                    Button(action: {
                        if members.count >= 50 {
                            showingTooManyMembersWarning.toggle()
                        } else {
                            showingAddMemberView.toggle()
                        }
                    }) {
                        HStack {
                            Image(systemName: "person.badge.plus.fill")
                            Text("Add member")
                        }
                    }
                    .alert(isPresented: $showingTooManyMembersWarning) {
                        Alert(title: Text("Waooooh!"), message: Text("Looks like you're a risk taker. You're about to exceed the maximum recommended number of members for an account! Our testing demonstrates that things work best where the number of members is less than 50. If you want to add more, go ahead, but know that you might get some unexpected behaviour."), primaryButton: .destructive(Text("Live dangerously"), action: { showingAddMemberView.toggle() }), secondaryButton: .cancel())
                    }
                    .fullScreenCover(isPresented: $showingAddMemberView) { AddMemberView(moc: moc, members: $members) }
                    ForEach(members, id: \.wrappedId) { member in
                        PersonListItemView(person: member, showingCheckmark: false)
                    }
                }
            }
            .navigationBarTitle(Text("Add new account"))
            .navigationBarItems(leading:
                Button("Cancel") { addAccountCancelled() },
                                trailing:
                Button("Save") { saveTrip() }.disabled(members.isEmpty || accountName.isEmpty)
            )
        }
    }
    
    func saveTrip() {
        guard accountName.count != 0 else { return } // white spaces
        guard members.count != 0 else { return }
        
        let account = Trip(context: moc)
        account.id = UUID()
        account.dateCreated = Date()
        account.name = accountName
        account.currenciesUsed?.insert(selectedBaseCurrency.rawValue, at: 0)
        
        // Convert to data
        if let inputImage = inputImage {
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
            try moc.save()
        } catch {
            print(error.localizedDescription)
        }
        
        presentationMode.wrappedValue.dismiss()
    }
    
    func addAccountCancelled() {
        // If there's a member, and they have an image, delete their image from device
        guard !members.isEmpty else {
            presentationMode.wrappedValue.dismiss()
            return
        }
        
        for member in members {
            // Check that the image is not just the default
            if let imageName = member.photo {
                FileManager.default.deleteData(from: imageName)
            }
            
            moc.delete(member) // Delete the member from moc
        }
        
        if moc.hasChanges { try? moc.save() } // save the moc
        
        // Dismiss the screen
        presentationMode.wrappedValue.dismiss()
        
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
