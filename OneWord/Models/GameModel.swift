//
//  GameModel.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/22/24.
//

import CloudKit

final class GameModel: ChildRecord {

    enum RecordKeys: String, CaseIterable {
        case inviteCode, name
    }
    
    static let recordType = "Game"
    
    var id: String
    var parent: User?
    
    
    // MARK: Database Record Keys
    
    var name: String
    var inviteCode: String
    
    
    // MARK: Initializers
    
    convenience init(withName name: String) {
        self.init()
        self.id = UUID().uuidString
        self.name = name
    }
    
    init?(from record: CKRecord, with parent: User) {
        fatalError("not implemented yet")
    }
    
    required init() { 
        self.id = UUID().uuidString
        self.name = ""
        self.inviteCode = String((0..<6).map { _ in "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890".randomElement()! })
    }
}
