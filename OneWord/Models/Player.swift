//
//  Player.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/25/24.
//

import CloudKit

final class Player: TwoParentsChildRecord {
    
    typealias Parent = User
    typealias SecondParent = Round
    
    enum RecordKeys: String, CaseIterable {
        case user, round, isWinner, isHost
    }
    
    static let recordType = "Question"

    var id: String
    
    // MARK: Database Record Keys
    
    var user: User?
    var round: Round?
    var isWinner: Bool
    var isHost: Bool
    
    
    // MARK: Initializers
    
    convenience init?(from record: CKRecord, with parent: User?) {
        guard let isWinner = record["isWinner"] as? Bool,
        let isHost = record["isHost"] as? Bool else {
            return nil
        }
        self.init()
        self.id = record.recordID.recordName
        self.isWinner = isWinner
        self.isHost = isHost
        self.user = parent
    }
    
    convenience init?(from record: CKRecord, with secondParent: Round?) {
        guard let isWinner = record["isWinner"] as? Bool,
        let isHost = record["isHost"] as? Bool else {
            return nil
        }
        self.init()
        self.id = record.recordID.recordName
        self.isWinner = isWinner
        self.isHost = isHost
        self.round = secondParent
    }
    
    required init() {
        self.isHost = false
        self.isWinner = false
        self.id = UUID().uuidString
    }
    
}