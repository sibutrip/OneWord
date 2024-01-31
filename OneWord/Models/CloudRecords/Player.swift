//
//  Player.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/25/24.
//

import CloudKit

struct Player: ChildRecord {
    
    typealias Parent = Round
    
    enum RecordKeys: String, CaseIterable {
        case user, round, rank, isHost
    }
    
    static let recordType = "Question"

    var id: String
    
    // MARK: Database Record Keys
    
    var user: User?
    var round: Round?
    var rank: Int?
    var isHost: Bool
    
    
    // MARK: Initializers
    
    init?(from record: CKRecord, with parent: Round?) {
        guard let isHost = record["isHost"] as? Bool,
        let userIdReference = record["user"] as? CKRecord.Reference else {
            return nil
        }
        self.init()
        self.id = record.recordID.recordName
        self.user = User(from: userIdReference)
        self.rank = record["rank"]
        self.isHost = isHost
        self.round = parent
    }
    
    init() {
        self.isHost = false
        self.id = UUID().uuidString
    }
    
    mutating func addingParent(_ parent: Round) {
        self.round = parent
    }
}
