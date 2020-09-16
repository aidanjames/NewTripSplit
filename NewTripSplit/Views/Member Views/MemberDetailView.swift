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
    @State private var hasLeft = false
    
    var saveButtonDisabled: Bool { return inputImage == nil && !showingEditNameField && member.hasLeft == hasLeft }
    
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
                        .onTapGesture { showingCameraOrPhotoLibActionSheet.toggle() }
                        .onAppear {
                            hasLeft = member.hasLeft
                            memberName = member.wrappedName
                        }
                }
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
                            inputImage = UIImage(named: "unknown")
                        },
                        .cancel()
                    ])
                }
                .sheet(isPresented: $showingImagePicker) {
                    ImagePicker(image: $inputImage, useCamera: useCamera)
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

                HStack {
                    Text("Has left? \(hasLeft ? "YES" : "NO")")
                    Button(action: { hasLeft = !hasLeft }) {
                        Text("\(hasLeft ? "Mark as back" : "Mark as left")")
                    }
                }
                
                Text(member.displayLocalBal)
                    .font(.body)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(BalancePosition.forPerson(member) == .owes ? Color.red : BalancePosition.forPerson(member) == .owed ? Color.green : Color.secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .opacity(50)
                    .alert(isPresented: $showingDeleteMemberAlert) {
                        Alert(title: Text("Are you sure?"), message: Text("Are you sure you want to delete this member? This is permanent and cannot be undone!"), primaryButton: .destructive(Text("Confirm"), action: {
                            deleteMember()
                        }), secondaryButton: .cancel())
                }
                List {
                    Section(header: Text("Paid for:")) {
                        if member.payerArray.isEmpty {
                            Text("Nothing!")
                        } else {
                            ForEach(member.payerArray, id: \.self) { transaction in
                                Button(action: showTransactionDetailView) {
                                    TransactionListItemView(transaction: transaction)
                                }
                                .sheet(isPresented: $showingTransactionDetailView) {
                                    TransactionDetailView(transaction: transaction, trip: account, moc: moc)
                                }
                            }
                        }
                    }
                    Section(header: Text("Beneficiary of:")) {
                        if member.beneficiaryArray.isEmpty {
                            Text("Nothing!")
                        } else {
                            ForEach(member.beneficiaryArray, id: \.self) { transaction in
                                Button(action: showTransactionDetailView) {
                                    TransactionListItemView(transaction: transaction)
                                }
                                .sheet(isPresented: $showingTransactionDetailView) {
                                    TransactionDetailView(transaction: transaction, trip: account, moc: moc)
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
                Button("Cancel") { presentationMode.wrappedValue.dismiss() },
                trailing:
                HStack {
                    Button(action: { deleteMemberInitialCheck() }) { Image(systemName: "trash") }.foregroundColor(.red).padding()
                    Button("Save") { saveButtonPressed() }.disabled(saveButtonDisabled)
                }
            )
        }
        .accentColor(.green)
    }
    
    func deleteMemberInitialCheck() {
        guard member.payerArray.isEmpty && member.beneficiaryArray.isEmpty else {
            showingCannotDeleteMemberAlert.toggle()
            return
        }
        showingDeleteMemberAlert.toggle()
    }
    
    func showTransactionDetailView() {
        showingTransactionDetailView.toggle()
    }
    
    func deleteMember() {
        if let imageName = member.photo {
            FileManager.default.deleteData(from: imageName) // Delete member image
        }
        account.removeFromPeople(member)
        if moc.hasChanges {
            try? moc.save()
        }
        presentationMode.wrappedValue.dismiss()
    }
    
    func saveButtonPressed() {

        member.name = memberName
        if inputImage != nil {
            // Delete old image
            if let imageName = member.photo {
                FileManager.default.deleteData(from: imageName)
            }
            // save image
            if let inputImage = inputImage {
                let imageID = UUID().uuidString
                // Convert to data
                if let jpegData = inputImage.jpegData(compressionQuality: 1) {
                    // Save to device
                    FileManager.default.writeData(jpegData, to: imageID)
                    member.photo = imageID
                }
            }
        }
        // Save 'hasLeft'
        member.hasLeft = hasLeft
        if moc.hasChanges {
            try? moc.save()
        }
        presentationMode.wrappedValue.dismiss()
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
