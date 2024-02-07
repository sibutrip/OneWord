//
//  FetchableGame.swift
//  CommandLineToolTest
//
//  Created by Cory Tripathy on 1/31/24.
//

struct FetchedGame: FetchedRecord {
    init?(from record: any DatabaseEntry) {
        guard let name = record["name"] as? String else {
            return nil
        }
        self.id = record.recordName
        self.name = name
    }
    
    static let recordType = "Game"
    
    let id: String
    let name: String
}
