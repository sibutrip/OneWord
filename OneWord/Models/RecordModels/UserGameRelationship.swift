//
//  CreatableUserGameRelationship.swift
//  CommandLineToolTest
//
//  Created by Cory Tripathy on 1/31/24.
//

import Foundation

struct UserGameRelationship: CreatableRecord, TwoParentsChildRecord {
    typealias Parent = User
    typealias SecondParent = Game
    
    enum RecordKeys: String, CaseIterable { case user, game }
    static let recordType = "UserGameRelationship"
    let id: String = UUID().uuidString
    let user: User
    let game: Game
}

struct FetchedUserGameRelationship: FetchedTwoParentsChild {
    typealias FetchedParent = FetchedUser
    typealias FetchedSecondParent = FetchedGame
    typealias Parent = User
    typealias SecondParent = Game
    init?(from entry: Entry) {
        // TODO: you don't need (and actually can't know) BOTH values. just one.
        let user = entry["user"] as? FetchedReference
        let game = entry["game"] as? FetchedReference
        self.id = entry.id
        self.user = user
        self.game = game
    }
    
    static let recordType = "Word"
    
    let id: String
    let user: FetchedReference?
    let game: FetchedReference?
    
    var parentReference: FetchedReference? { return user }
    var secondParentReference: FetchedReference? { return game }
}
