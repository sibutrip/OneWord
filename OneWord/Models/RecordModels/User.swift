//
//  CreatableUser.swift
//  CommandLineToolTest
//
//  Created by Cory Tripathy on 1/31/24.
//

import Foundation

struct User: CreatableRecord, Identifiable {
    enum RecordKeys: String, CaseIterable { case name, systemID }
    static let recordType = "User"
    let id: String
    let name: String
    let systemID: String
    init(id: String = UUID().uuidString, name: String, systemID: String) {
        self.id = id
        self.name = name
        self.systemID = systemID
    }
}

struct FetchedUser: FetchedRecord {
    init?(from entry: Entry) {
        guard let name = entry["name"] as? String,
              let systemID = entry["systemID"] as? String else {
            return nil
        }
        self.id = entry.id
        self.name = name
        self.systemID = systemID
    }
    
    static let recordType = "User"
    
    let id: String
    let name: String
    let systemID: String
}
