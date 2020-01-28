//
//  Betting.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 16/01/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//

import Foundation

class Betting: ObservableObject {
    @Published var allBets = [Odds]() 
    
    static let saveKey = "SavedBetting"
    
    init() {
        if let bets: [Odds] = FileManager.default.fetchData(from: Self.saveKey) {
                        
            self.allBets = bets
            return
        }
        self.allBets = []
    }
    
    private func save() {
        FileManager.default.writeData(allBets, to: Self.saveKey)
    }
    
    func add(_ odds: Odds) {
        allBets.insert(odds, at: 0)
        save()
    }
    
    func update() {
        print("Update called... should be reloading now.")
        save()
    }
    
    func delete(_ odds: Odds) {
        if let index = self.allBets.firstIndex(where: { $0.id == odds.id }) {
            self.allBets.remove(at: index)
            save()
        }
    }
    
}

//class Prospects: ObservableObject {
//    @Published private(set) var people: [Prospect]
//
//    static let saveKey = "SavedData"
//
//    init() {
//        if let prospectos: [Prospect] = FileManager.default.fetchData(from: Self.saveKey) {
//            for pros in prospectos {
//                print(pros.name)
//            }
//
//            self.people = prospectos
//            return
//        }
//        self.people = []
//    }
//
//    func add(_ prospect: Prospect) {
//        people.append(prospect)
//        save()
//    }
//
//    func delete(_ prospect: Prospect) {
//        if let index = self.people.firstIndex(where: { $0.id == prospect.id }) {
//            self.people.remove(at: index)
//            save()
//        }
//    }
//
//    private func save() {
//        if let encoded = try? JSONEncoder().encode(people) {
//            UserDefaults.standard.set(encoded, forKey: Self.saveKey)
//        }
//
//        // Save to documents directory instead of user defaults
//        FileManager.default.writeData(people, to: Self.saveKey)
//    }
//
//    func toggle(_ prospect: Prospect) {
//        objectWillChange.send()
//        prospect.isContacted.toggle()
//        save()
//    }
//
//    func sort(by sortingPredacate: SortingPredacate) {
//        switch sortingPredacate {
//        case .nameAscending:
//            people.sort { $0.name < $1.name }
//        case .nameDescending:
//            people.sort { $0.name > $1.name }
//        case .dateAddedAscending:
//            people.sort { $0.dateAdded < $1.dateAdded }
//        default:
//            people.sort { $0.dateAdded > $1.dateAdded }
//        }
//    }
//}
