//
//  UserGameRelationship.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/24/24.
//

import CloudKit

struct UserGameRelationship: TwoParentsChildRecord {
    
    typealias Parent = User
    typealias SecondParent = Game
    
    enum RecordKeys: String, CaseIterable {
        case user, game
    }
    
    static let recordType = "UserGameRelationship"

    var id: String
    var user: User?
    var game: Game?
    
    
    // MARK: Initializers
    
    init(user: User, game: Game) {
        self.init()
        self.user = user
        self.game = game
    }
    
    init?(from record: CKRecord, with parent: User?) {
        self.init()
        self.id = record.recordID.recordName
        self.user = parent
    }
    
    init?(from record: CKRecord, with secondParent: Game?) {
        self.init()
        self.id = record.recordID.recordName
        self.game = secondParent
    }
    
    init() {
        self.id = UUID().uuidString
    }
    
    mutating func addingParent(_ parent: User) {
        self.user = parent
    }
    
    mutating func addingSecondParent(_ secondParent: Game) {
        self.game = secondParent
    }
}
