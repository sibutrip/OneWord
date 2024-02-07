//
//  CreatableWord.swift
//  CommandLineToolTest
//
//  Created by Cory Tripathy on 1/31/24.
//

struct Word: CreatableRecord {
    enum RecordKeys: String, CaseIterable { case description, user, round }
    static let recordType = "Word"
    let id: String
    let description: String
    let user: User
    let round: Round
}
