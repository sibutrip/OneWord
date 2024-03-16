//
//  CreatableGame.swift
//  CommandLineToolTest
//
//  Created by Cory Tripathy on 1/31/24.
//

import Foundation

struct Game: CreatableRecord {
    enum RecordKeys: String, CaseIterable { case GroupName }
    static let recordType = "Game"
    let id: String
    let groupName: String
    init(id: String = UUID().uuidString, groupName: String) {
        self.id = id
        self.groupName = groupName
    }
}

struct FetchedGame: FetchedRecord {
    enum RecordKeys: String, CaseIterable { case GroupName }
    init?(from entry: Entry) {
        guard let groupName = entry["GroupName"] as? String else {
            return nil
        }
        self.id = entry.id
        self.groupName = groupName
    }
    
    static let recordType = "Game"
    
    let id: String
    let groupName: String
}

extension Game: Hashable { }
