//
//  UserGameRelationship.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/24/24.
//

import CloudKit

struct UserGameRelationship: TwoParentsChildRecord {
    
    typealias Parent = User
    typealias SecondParent = GameModel
    
    enum RecordKeys: String, CaseIterable {
        case user, game
    }
    
    static let recordType = "UserGameRelationship"

    var id: String
    var user: User?
    var gameModel: GameModel?
    
    
    // MARK: Initializers
    
    init(user: User, game: GameModel) {
        self.init()
        self.user = user
        self.gameModel = game
    }
    
    init?(from record: CKRecord, with parent: User?) {
        self.init()
        self.id = record.recordID.recordName
        self.user = parent
    }
    
    init?(from record: CKRecord, with secondParent: GameModel?) {
        self.init()
        self.id = record.recordID.recordName
        self.gameModel = secondParent
    }
    
    init() {
        self.id = UUID().uuidString
    }
    
    mutating func addingParent(_ parent: User) {
        self.user = parent
    }
    
    mutating func addingSecondParent(_ secondParent: GameModel) {
        self.gameModel = secondParent
    }
}
