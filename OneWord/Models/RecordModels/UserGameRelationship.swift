//
//  CreatableUserGameRelationship.swift
//  CommandLineToolTest
//
//  Created by Cory Tripathy on 1/31/24.
//

struct UserGameRelationship: CreatableRecord {
    enum RecordKeys: String, CaseIterable { case user, game }
    static let recordType = "UserGameRelationship"
    let id: String
    let user: User
    let game: Game
}

struct FetchedUserGameRelationship: FetchedTwoParentsChild {
    typealias Parent = User
    typealias SecondParent = Game
    init?(from entry: Entry) {
        // TODO: you don't need (and actually can't know) BOTH values. just one.
        guard let user = entry["user"] as? FetchedReference,
              let game = entry["game"] as? FetchedReference else {
            return nil
        }
        self.id = entry.id
        self.user = user
        self.game = game
    }
    
    static let recordType = "Word"
    
    let id: String
    let user: FetchedReference
    let game: FetchedReference
    
    var parentReference: FetchedReference { return user }
    var secondParentReference: FetchedReference { return game }
    
}
