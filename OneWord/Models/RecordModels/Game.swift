//
//  CreatableGame.swift
//  CommandLineToolTest
//
//  Created by Cory Tripathy on 1/31/24.
//

import Foundation

struct Game: CreatableRecord {
    enum RecordKeys: String, CaseIterable { case GroupName, InviteCode }
    static let recordType = "Game"
    let id: String
    let groupName: String
    let inviteCode: String
    init(id: String = UUID().uuidString, groupName: String, inviteCode: String? = nil) {
        self.id = id
        self.groupName = groupName
        self.inviteCode = inviteCode ?? String((0..<6).map { _ in "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890".randomElement()! })
    }
}

struct FetchedGame: FetchedRecord {
    enum RecordKeys: String, CaseIterable { case GroupName, InviteCode }
    init?(from entry: Entry) {
        guard let groupName = entry["GroupName"] as? String,
        let inviteCode = entry["InviteCode"] as? String else {
            return nil
        }
        self.id = entry.id
        self.groupName = groupName
        self.inviteCode = inviteCode
    }
    
    static let recordType = "Game"
    
    let id: String
    let groupName: String
    let inviteCode: String
}

extension Game: Hashable { }
