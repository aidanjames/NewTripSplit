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
    
    var saveButtonDisabled: Bool { return inputImage == nil && accountName == account.wrappedName }
    
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
                            .padding(.top)
                    } else {
                        account.wrappedAccountImage
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 250, height: 250)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .padding(.top)
                    }
                    Image(systemName: "camera.fill")
                    .font(.largeTitle)
                    .foregroundColor(.blue)
                    .offset(x: 0, y: 95)
                    .padding()
                    .onTapGesture { showingCameraOrPhotoLibActionSheet.toggle() }
                    .actionSheet(isPresented: $showingCameraOrPhotoLibActionSheet) {
                        ActionSheet(title: Text("Change photo"), buttons: [
                            .default(Text("Take a photo")) {
                                useCamera = true
                                showingImagePicker.toggle()
                            },
                            .default(Text("Use photo album")) {
                                useCamera = false
                                showingImagePicker.toggle()
                            },
                            .default(Text("Delete image (use default)")) {
                                inputImage = UIImage(named: account.wrappedBaseCurrency.prefix(3).lowercased())
                            },
                            .cancel()
                        ])
                    }
                    .sheet(isPresented: $showingImagePicker) {
                        ImagePicker(image: $inputImage, useCamera: useCamera)
                    }
                }
                
                TextField("", text: $accountName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(.center)
                    .frame(width: 300)
                    .padding()
                    .onAppear(perform: populateTripName)
                .alert(isPresented: $showingDeleteAccountWarning) {
                    Alert(title: Text("Are you sure?"), message: Text("Are you sure you want to delete this account? This is permanent and cannot be undone!"), primaryButton: .destructive(Text("Confirm"), action: {
                        deleteAccount()
                    }), secondaryButton: .cancel())
                }
                
                Text("Base currency: \(account.wrappedBaseCurrency)")
                    .padding(.bottom)

                Button(action: { showingAddMemberView.toggle() }) {
                    HStack {
                        Image(systemName: "person.badge.plus.fill")
                        Text("Add member")
                        Spacer()
                    }.padding(.leading)
                }
                .sheet(isPresented: $showingAddMemberView) { AddMemberView(moc: moc, members: $tempMembers) }
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
                Button("Cancel") { presentationMode.wrappedValue.dismiss() },
                trailing:
                HStack {
                    Button(action: { showingDeleteAccountWarning.toggle() }) { Image(systemName: "trash") }.foregroundColor(.red).padding()
                    Button("Save") { saveButtonPressed() }.disabled(saveButtonDisabled)
                }
            )
        }
    }
    
    func populateTripName() {
        accountName = account.wrappedName
    }
    
    
    func deleteAccount() {
        account.deleteSettlement()
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
        
        let betting = Betting() // Delete bets
        for betOffer in betting.allBets.filter({ $0.tripId == account.wrappedId }) {
            if let index = betting.allBets.firstIndex(where: { $0.id == betOffer.id } ) {
                betting.allBets.remove(at: index)
            }
        }
        betting.update()
                
        if let imageName = account.image {
            FileManager.default.deleteData(from: imageName) // Delete account image
        }
        
        moc.delete(account)
        
        if moc.hasChanges {
            try? moc.save()
        }
        
        presentationMode.wrappedValue.dismiss()
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
            if let inputImage = inputImage {
                let imageID = UUID().uuidString
                // Convert to data
                if let jpegData = inputImage.jpegData(compressionQuality: 1) {
                    // Save to device
                    FileManager.default.writeData(jpegData, to: imageID)
                    account.image = imageID
                }
            }
        }
        if moc.hasChanges {
            try? moc.save()
        }
       
        presentationMode.wrappedValue.dismiss()
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
