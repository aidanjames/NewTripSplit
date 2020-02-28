//
//  EditAccountView.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 28/02/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//

import CoreData
import SwiftUI

struct EditAccountView: View {
    
    var moc: NSManagedObjectContext
    var account: Trip
    @Environment(\.presentationMode) var presentationMode
    
    @State private var accountName = ""
    @State private var showingAddMemberView = false
    @State private var tempMembers = [Person]()
    
    @State private var showingDeleteAccountWarning = false
    
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var showingCameraOrPhotoLibActionSheet = false
    @State private var useCamera = false
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    if inputImage != nil {
                        Image(uiImage: inputImage!)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 250, height: 250)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .padding()
                    } else {
                        account.wrappedAccountImage
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 250, height: 250)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .padding()
                    }
                    Image(systemName: "camera.fill")
                    .font(.largeTitle)
                    .foregroundColor(.blue)
                    .offset(x: 0, y: 95)
                    .padding()
                    .onTapGesture { self.showingCameraOrPhotoLibActionSheet.toggle() }
                    .actionSheet(isPresented: self.$showingCameraOrPhotoLibActionSheet) {
                        ActionSheet(title: Text("Change photo"), buttons: [
                            .default(Text("Take a photo")) {
                                self.useCamera = true
                                self.showingImagePicker.toggle()
                            },
                            .default(Text("Use photo album")) {
                                self.useCamera = false
                                self.showingImagePicker.toggle()
                            },
                            .default(Text("Delete image (use default)")) {
                                self.inputImage = UIImage(named: self.account.wrappedBaseCurrency.prefix(3).lowercased())
                            },
                            .cancel()
                        ])
                    }
                    .sheet(isPresented: $showingImagePicker) {
                        ImagePicker(image: self.$inputImage, useCamera: self.useCamera)
                    }
                }
                
                TextField("", text: $accountName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(.center)
                    .padding()
                    .onAppear(perform: self.populateTripName)
                
                Button(action: { self.showingDeleteAccountWarning.toggle() }) {
                    Text("Delete account").foregroundColor(.red)
                }
                .padding(.bottom)
                .alert(isPresented: $showingDeleteAccountWarning) {
                    Alert(title: Text("Are you sure?"), message: Text("Are you sure you want to delete this account? This is permanent and cannot be undone!"), primaryButton: .default(Text("Confirm"), action: {
                        self.deleteAccount()
                    }), secondaryButton: .cancel())
                }

                Button(action: { self.showingAddMemberView.toggle() }) {
                    HStack {
                        Image(systemName: "person.badge.plus.fill")
                        Text("Add member")
                        Spacer()
                    }.padding(.leading)
                }
                .sheet(isPresented: $showingAddMemberView) { AddMemberView(moc: self.moc, members: self.$tempMembers) }
                List {
                    ForEach(account.sortedPeopleArray, id: \.self) { member in
                        PersonListItemView(person: member, showingCheckmark: false)
                    }
                    ForEach(tempMembers, id: \.self) { member in
                        PersonListItemView(person: member, showingCheckmark: false)
                    }
                }
            }
            .navigationBarTitle(Text("Edit account"), displayMode: .inline)
            .navigationBarItems(
                leading:
                Button("Cancel") { self.presentationMode.wrappedValue.dismiss() },
                trailing:
                Button("Save") { self.saveButtonPressed() }
            )
        }
    }
    
    func populateTripName() {
        self.accountName = account.wrappedName
    }
    
    
    func deleteAccount() {
        for member in account.sortedPeopleArray {
            // Delete old image
            if let imageName = member.photo {
                FileManager.default.deleteData(from: imageName) // Delete member image
            }
            moc.delete(member)
        }
        
        for transaction in account.transactionsArray {
            if let imageName = transaction.photo {
                FileManager.default.deleteData(from: imageName) // Delete receipt image
            }
            moc.delete(transaction)
        }
        // TODO: Need to delete bet wagers
        
        // TODO: Need to delete bet offers
        
        if let imageName = account.image {
            FileManager.default.deleteData(from: imageName) // Delete account image
        }
        
        moc.delete(account)
        
        if self.moc.hasChanges {
            try? self.moc.save()
        }
        
        self.presentationMode.wrappedValue.dismiss()
    }
    
    func saveButtonPressed() {
        if !tempMembers.isEmpty {
            for member in tempMembers {
                account.addToPeople(member)
            }
        }
        if accountName != account.wrappedName {
            account.name = accountName
        }
        if inputImage != nil {
            // Delete old image
            if let imageName = account.image {
                FileManager.default.deleteData(from: imageName)
            }
            // save image
            if let inputImage = self.inputImage {
                let imageID = UUID().uuidString
                // Convert to data
                if let jpegData = inputImage.jpegData(compressionQuality: 1) {
                    // Save to device
                    FileManager.default.writeData(jpegData, to: imageID)
                    account.image = imageID
                }
            }
        }
        if self.moc.hasChanges {
            try? self.moc.save()
        }
       
        self.presentationMode.wrappedValue.dismiss()
    }
}

struct EditAccountView_Previews: PreviewProvider {
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
        return EditAccountView(moc: moc, account: trip)
    }
}
