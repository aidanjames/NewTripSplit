//
//  MemberDetailView.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 22/02/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//

import CoreData
import SwiftUI

struct MemberDetailView: View {
    
    @ObservedObject var member: Person
    @ObservedObject var account: Trip
    var moc: NSManagedObjectContext
    
    @State private var showingTransactionDetailView = false
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var showingCameraOrPhotoLibActionSheet = false
    @State private var useCamera = false
    @State private var memberName = ""
    @State private var showingEditNameField = false
    @State private var showingDeleteMemberAlert = false
    @State private var showingCannotDeleteMemberAlert = false
    
    var saveButtonDisabled: Bool { return inputImage == nil && !showingEditNameField }
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    if inputImage != nil {
                        Image(uiImage: inputImage!)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 250, height: 250)
                            .clipShape(Circle())
                            .padding(.top)
                    } else {
                        member.wrappedMemberImage
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 250, height: 250)
                            .clipShape(Circle())
                            .padding(.top)
                    }
                    
                    Image(systemName: "camera.fill")
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                        .offset(x: 0, y: 95)
                        .padding()
                        .onTapGesture { self.showingCameraOrPhotoLibActionSheet.toggle() }
                }
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
                            self.inputImage = UIImage(named: "unknown")
                        },
                        .cancel()
                    ])
                }
                .sheet(isPresented: $showingImagePicker) {
                    ImagePicker(image: self.$inputImage, useCamera: self.useCamera)
                }
                
                if !showingEditNameField {
                    HStack {
                        Text("\(member.wrappedName)")
                        Button("Edit") {
                            memberName = member.wrappedName
                            withAnimation {
                                showingEditNameField.toggle()
                            }
                        }
                    }.padding()
                }
                
                if showingEditNameField {
                    TextField("", text: $memberName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .multilineTextAlignment(.center)
                        .frame(width: 250)
                        
                }

                Text("\(member.localBal < -0.099 ? "Owes \(member.displayLocalBal)" : member.localBal > 0.099 ? "Owed \(member.displayLocalBal)" : "All square")")
                    .font(.body)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(member.localBal < -0.0099 ? Color.red : member.localBal > 0.0099 ? Color.green : Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .opacity(50)
                    .alert(isPresented: $showingDeleteMemberAlert) {
                        Alert(title: Text("Are you sure?"), message: Text("Are you sure you want to delete this member? This is permanent and cannot be undone!"), primaryButton: .destructive(Text("Confirm"), action: {
                            self.deleteMember()
                        }), secondaryButton: .cancel())
                }
                List {
                    Section(header: Text("Paid for:")) {
                        if member.payerArray.isEmpty {
                            Text("Nothing!")
                        } else {
                            ForEach(member.payerArray, id: \.self) { transaction in
                                Button(action: self.showTransactionDetailView) {
                                    TransactionListItemView(transaction: transaction)
                                }
                                .sheet(isPresented: self.$showingTransactionDetailView) {
                                    TransactionDetailView(transaction: transaction, trip: self.account, moc: self.moc)
                                }
                            }
                        }
                    }
                    Section(header: Text("Beneficiary of:")) {
                        if member.beneficiaryArray.isEmpty {
                            Text("Nothing!")
                        } else {
                            ForEach(member.beneficiaryArray, id: \.self) { transaction in
                                Button(action: self.showTransactionDetailView) {
                                    TransactionListItemView(transaction: transaction)
                                }
                                .sheet(isPresented: self.$showingTransactionDetailView) {
                                    TransactionDetailView(transaction: transaction, trip: self.account, moc: self.moc)
                                }
                            }
                        }
                    }
                    .alert(isPresented: $showingCannotDeleteMemberAlert) {
                        Alert(title: Text("Cannot delete member"), message: Text("The member cannot be deleted because they are linked to ative expenses."), dismissButton: .cancel(Text("OK")))
                    }
                }
                Spacer()
            }
            .navigationBarTitle(Text("Edit member"), displayMode: .inline)
            .navigationBarItems(
                leading:
                Button("Cancel") { self.presentationMode.wrappedValue.dismiss() },
                trailing:
                HStack {
                    Button(action: { self.deleteMemberInitialCheck() }) { Image(systemName: "trash") }.foregroundColor(.red).padding()
                    Button("Save") { self.saveButtonPressed() }.disabled(saveButtonDisabled)
                }
            )
        }
        .accentColor(.green)
    }
    
    func deleteMemberInitialCheck() {
        guard member.payerArray.isEmpty && member.beneficiaryArray.isEmpty else {
            self.showingCannotDeleteMemberAlert.toggle()
            return
        }
        self.showingDeleteMemberAlert.toggle()
    }
    
    func showTransactionDetailView() {
        self.showingTransactionDetailView.toggle()
    }
    
    func deleteMember() {
        if let imageName = member.photo {
            FileManager.default.deleteData(from: imageName) // Delete member image
        }
        account.removeFromPeople(member)
        if self.moc.hasChanges {
            try? self.moc.save()
        }
        self.presentationMode.wrappedValue.dismiss()
    }
    
    func saveButtonPressed() {
        if memberName != member.wrappedName {
            member.name = memberName
        }
        if inputImage != nil {
            // Delete old image
            if let imageName = member.photo {
                FileManager.default.deleteData(from: imageName)
            }
            // save image
            if let inputImage = self.inputImage {
                let imageID = UUID().uuidString
                // Convert to data
                if let jpegData = inputImage.jpegData(compressionQuality: 1) {
                    // Save to device
                    FileManager.default.writeData(jpegData, to: imageID)
                    member.photo = imageID
                }
            }
        }
        if self.moc.hasChanges {
            try? self.moc.save()
        }
        self.presentationMode.wrappedValue.dismiss()
    }
}

struct MemberDetailView_Previews: PreviewProvider {
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
        person1.name = "Sharon Bates"
        person1.photo = "person2"
        trip.addToPeople(person)
        trip.addToPeople(person1)
        return MemberDetailView(member: person1, account: trip, moc: moc)
    }
}
