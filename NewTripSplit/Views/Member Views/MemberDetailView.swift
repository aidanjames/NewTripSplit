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
                            .padding()
                    } else {
                        member.wrappedMemberImage
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 250, height: 250)
                            .clipShape(Circle())
                            .padding()
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
                        .cancel()
                    ])
                }
                .sheet(isPresented: $showingImagePicker) {
                    ImagePicker(image: self.$inputImage, useCamera: self.useCamera)
                }
                Text("\(member.localBal < -0.099 ? "Owes \(member.displayLocalBal)" : member.localBal > 0.099 ? "Owed \(member.displayLocalBal)" : "All square")")
                    .font(.body)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(member.localBal < -0.099 ? Color.red : member.localBal > 0.099 ? Color.green : Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .opacity(50)
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
                    
                }
                Spacer()
            }
            .navigationBarTitle(Text(member.wrappedName), displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") { self.donePressed() })
        }
    }
    
    func showTransactionDetailView() {
        self.showingTransactionDetailView.toggle()
    }
    
    func donePressed() {
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
