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
