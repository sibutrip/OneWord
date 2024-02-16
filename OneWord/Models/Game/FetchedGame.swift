//
//  FetchableGame.swift
//  CommandLineToolTest
//
//  Created by Cory Tripathy on 1/31/24.
//

struct FetchedGame: FetchedRecord {
    init?(from entry: Entry) {
        guard let name = entry["name"] as? String else {
            return nil
        }
        self.id = entry.id
        self.name = name
    }
    
    static let recordType = "Game"
    
    let id: String
    let name: String
}
