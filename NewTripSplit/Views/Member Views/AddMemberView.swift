//
//  AddMemberView.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 28/01/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//

import CoreData
import SwiftUI

struct AddMemberView: View {
    
    var moc: NSManagedObjectContext
    @Binding var members: [Person]
    
    @State private var name = ""
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var showingCameraOrPhotoLibActionSheet = false
    @State private var useCamera = false
    
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
                            showingCameraOrPhotoLibActionSheet.toggle()
                        }
                        .actionSheet(isPresented: $showingCameraOrPhotoLibActionSheet) {
                            ActionSheet(title: Text("Add photo"), buttons: [
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
            }
            .navigationBarTitle(Text("New member"))
            .navigationBarItems(
                leading:
                Button("Cancel") { presentationMode.wrappedValue.dismiss() },
                trailing:
                Button("Add to account") { saveMember() })
        }
        .accentColor(.green)
    }
    
    func saveMember() {
        guard name.count > 0 else { return }
        let member = Person(context: moc)
        member.id = UUID()
        member.name = name
        member.isSelected = true
        member.defaultAsBeneficiary = true
        
        // Convert to data
        if let inputImage = inputImage {
            let imageID = UUID().uuidString
            if let jpegData = inputImage.jpegData(compressionQuality: 1) {
                // Save to device
                FileManager.default.writeData(jpegData, to: imageID)
                member.photo = imageID
            }
        }
        members.append(member)
          
        // Fixes an issue with attempting to update state whilst it is being rendered.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            presentationMode.wrappedValue.dismiss()
        }
        
    }
    
    
}

struct AddMemberView_Previews: PreviewProvider {
    static var previews: some View {
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let person1 = Person(context: moc)
        person1.name = "Aidan James"
        person1.photo = "person1"
        person1.id = UUID()
        
        return AddMemberView(moc: moc, members: .constant([person1]))
    }
}
