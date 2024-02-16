//
//  FetchedUser.swift
//  CommandLineToolTest
//
//  Created by Cory Tripathy on 1/31/24.
//

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
