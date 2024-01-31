//
//  Game.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/22/24.
//

import CloudKit

struct Game: ManyToManyRecord {
    
    typealias RelatedRecord = User
    typealias Child = UserGameRelationship

    enum RecordKeys: String, CaseIterable {
        case inviteCode, name
    }
    
    static let recordType = "Game"
    
    var id: String
    
    
    // MARK: Database Record Keys
    
    var name: String
    var inviteCode: String
    
    
    // MARK: Initializers
    
    init(withName name: String) {
        self.id = UUID().uuidString
        self.name = name
        self.inviteCode = String((0..<6).map { _ in "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890".randomElement()! })
    }
    
    init?(from record: CKRecord) {
        guard let name = record["name"] as? String else {
            return nil
        }
        self.init(withName: name)
        self.id = record.recordID.recordName
    }
}
