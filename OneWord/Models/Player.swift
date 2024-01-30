//
//  Player.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/25/24.
//

import CloudKit

struct Player: TwoParentsChildRecord {
    
    typealias Parent = User
    typealias SecondParent = Round
    
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
    
    init?(from record: CKRecord, with parent: User?) {
        guard let isHost = record["isHost"] as? Bool else {
            return nil
        }
        self.init()
        self.id = record.recordID.recordName
        self.rank = record["rank"]
        self.isHost = isHost
        self.user = parent
    }
    
    init?(from record: CKRecord, with secondParent: Round?) {
        guard let isHost = record["isHost"] as? Bool else {
            return nil
        }
        self.init()
        self.id = record.recordID.recordName
        self.rank = record["rank"]
        self.isHost = isHost
        self.round = secondParent
    }
    
    init() {
        self.isHost = false
        self.id = UUID().uuidString
    }
    
    mutating func addingParent(_ parent: User) {
        self.user = parent
    }
    
    mutating func addingSecondParent(_ secondParent: Round) {
        self.round = secondParent
    }
}
