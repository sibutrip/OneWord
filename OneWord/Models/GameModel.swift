//
//  GameModel.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/22/24.
//

import CloudKit

final class GameModel: ManyToManyRecord {
    
    typealias RelatedRecord = User


    enum RecordKeys: String, CaseIterable {
        case inviteCode, name
    }
    
    static let recordType = "Game"
    
    var id: String
    
    
    // MARK: Database Record Keys
    
    var name: String
    var inviteCode: String
    
    
    // MARK: Initializers
    
    required init(withName name: String) {
        self.id = UUID().uuidString
        self.name = name
        self.inviteCode = String((0..<6).map { _ in "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890".randomElement()! })
    }
    
    init?(from record: CKRecord) {
        fatalError("not implemented yet")
    }
}
