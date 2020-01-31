//
//  AddMemberToTripView.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 31/01/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//

import CoreData
import SwiftUI

struct AddMemberToTripView: View {
    
    var moc: NSManagedObjectContext
    var account: Trip
    
    @State private var name = ""
    @State private var showingImagePickerView = false
    @State private var inputImage: UIImage?
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                
                Section(header: Text("Member details")) {
                    TextField("Member name", text: $name)
                }
                
                Section(header: Text("Image").font(.body)) {
                    HStack {
                        if inputImage != nil {
                            Image(uiImage: inputImage!)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                        } else {
                            Image("unknown")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                        }
                        
                        Button("Change") {
                            self.showingImagePickerView.toggle()
                        }
                        .sheet(isPresented: $showingImagePickerView) {
                            ImagePicker(image: self.$inputImage)
                        }
                    }
                }
            }
            .navigationBarTitle(Text("New member"))
            .navigationBarItems(
                leading:
                Button("Cancel") { self.presentationMode.wrappedValue.dismiss() },
                trailing:
                Button("Add to account") { self.saveMember() })
        }
    }
    
    func saveMember() {
        guard name.count > 0 else { return }
        let member = Person(context: self.moc)
        member.id = UUID()
        member.name = self.name
        member.isSelected = true
        
        // Convert to data
        if let inputImage = self.inputImage {
            let imageID = UUID().uuidString
            if let jpegData = inputImage.jpegData(compressionQuality: 1) {
                // Save to device
                FileManager.default.writeData(jpegData, to: imageID)
                member.photo = imageID
            }
        }
        
        member.trip = self.account
        account.addToPeople(member)
        try? self.moc.save()
        
        self.presentationMode.wrappedValue.dismiss()

    }
    
    
}

struct AddMemberToTripView_Previews: PreviewProvider {
    static var previews: some View {
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let person1 = Person(context: moc)
        person1.name = "Aidan James"
        person1.photo = "person1"
        person1.id = UUID()
        let account = Trip(context: moc)
        account.id = UUID()
        
        
        return AddMemberToTripView(moc: moc, account: account)
    }
}
