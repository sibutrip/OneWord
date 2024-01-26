//
//  UserGameRelationship.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/24/24.
//

import CloudKit

final class UserGameRelationship: TwoParentsChildRecord {
    
    typealias Parent = User
    typealias SecondParent = GameModel
    
    enum RecordKeys: String, CaseIterable {
        case user, game, parent, secondParent
    }
    
    static let recordType = "UserGameRelationship"

    var id: String
    var user: User?
    var gameModel: GameModel?
    
    
    // MARK: Initializers
    
    convenience init(user: User, game: GameModel) {
        self.init()
        self.user = user
        self.gameModel = game
    }
    
    convenience init?(from record: CKRecord, with parent: User?) {
        self.init()
        self.id = record.recordID.recordName
        self.user = parent
    }
    
    convenience init?(from record: CKRecord, with secondParent: GameModel?) {
        self.init()
        self.id = record.recordID.recordName
        self.gameModel = secondParent
    }
    
    required init() {
        self.id = UUID().uuidString
    }
}
