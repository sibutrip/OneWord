//
//  UserGameRelationship.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/24/24.
//

import CloudKit

final class UserGameRelationship: TwoParentsChildRecord {
    
    enum RecordKeys: String, CaseIterable {
        case user, game
    }
    
    static let recordType = "UserGameRelationship"

    var id: String
    var parent: User?
    var secondParent: GameModel?
    
    
    // MARK: Initializers
    
    convenience init(user: User, game: GameModel) {
        self.init()
        self.parent = user
        self.secondParent = game
    }
    
    convenience init?(from record: CKRecord, with parent: User?) {
        self.init()
        self.id = record.recordID.recordName
        self.parent = parent
    }
    
    convenience init?(from record: CKRecord, with secondParent: GameModel?) {
        self.init()
        self.id = record.recordID.recordName
        self.secondParent = secondParent
    }
    
    required init() {
        self.id = UUID().uuidString
    }
}
