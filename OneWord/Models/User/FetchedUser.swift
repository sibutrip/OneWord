//
//  FetchedUser.swift
//  CommandLineToolTest
//
//  Created by Cory Tripathy on 1/31/24.
//

struct FetchedUser: FetchedRecord {
    init?(from record: any DatabaseEntry) {
        guard let name = record["name"] as? String,
              let systemID = record["systemID"] as? String else {
            return nil
        }
        self.id = record.recordName
        self.name = name
        self.systemID = systemID
    }
    
    static let recordType = "User"
    
    let id: String
    let name: String
    let systemID: String
}
