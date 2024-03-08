//
//  CreatableGame.swift
//  CommandLineToolTest
//
//  Created by Cory Tripathy on 1/31/24.
//

import Foundation

struct Game: CreatableRecord {
    enum RecordKeys: String, CaseIterable { case groupName }
    static let recordType = "Game"
    let id: String = UUID().uuidString
    let groupName: String
}

struct FetchedGame: FetchedRecord {
    init?(from entry: Entry) {
        guard let groupName = entry["groupName"] as? String else {
            return nil
        }
        self.id = entry.id
        self.groupName = groupName
    }
    
    static let recordType = "Game"
    
    let id: String
    let groupName: String
}
