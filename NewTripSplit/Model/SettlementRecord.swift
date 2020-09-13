//
//  SettlementRecord.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 02/09/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//

import Foundation

struct SettlementRecord: Identifiable {
    var id = UUID()
    var from: Person
    var to: Person
    var amount: Double
    var paid = false
}

struct SettlementRecords {
    var tripId: UUID
    var records: [SettlementRecord]
}


struct SaveableSettlementRecord: Codable {
    var id = UUID()
    var fromId: UUID
    var toId: UUID
    var amount: Double
    var paid = false
}

struct SaveableSettlementRecords: Codable {
    var tripId: UUID
    var records: [SaveableSettlementRecord]
}
