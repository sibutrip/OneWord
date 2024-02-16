//
//  CreatableGame.swift
//  CommandLineToolTest
//
//  Created by Cory Tripathy on 1/31/24.
//

struct Game: CreatableRecord {
    enum RecordKeys: String, CaseIterable { case name }
    static let recordType = "Game"
    let id: String
    let name: String
    
    // Not a record key, passed through initialization
    let user: User
}

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
