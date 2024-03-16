//
//  CreatableUser.swift
//  CommandLineToolTest
//
//  Created by Cory Tripathy on 1/31/24.
//

import Foundation

struct User: CreatableRecord, Identifiable {
    enum RecordKeys: String, CaseIterable { case Name, SystemID }
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
    enum RecordKeys: String, CaseIterable { case Name, SystemID }
    init?(from entry: Entry) {
        guard let name = entry["Name"] as? String,
              let systemID = entry["SystemID"] as? String else {
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

extension User: Hashable { }
