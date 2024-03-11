//
//  CreatableRound.swift
//  CommandLineToolTest
//
//  Created by Cory Tripathy on 1/31/24.
//

import Foundation

struct Round: CreatableRecord, ChildRecord {
    typealias Parent = Game
    enum RecordKeys: String, CaseIterable { case game, question, host }
    static let recordType = "Round"
    let id: String
    let localUser: LocalUser
    let game: Game
    let question: Question
    let host: User
    init(id: String = UUID().uuidString, localUser: LocalUser, game: Game, question: Question, host: User) {
        self.id = id
        self.localUser = localUser
        self.game = game
        self.question = question
        self.host = host
    }
}

struct FetchedRound: FetchedRecord, ChildRecord {
    typealias Parent = Game
    init?(from entry: Entry) {
        guard let game = entry["game"] as? FetchedReference,
              let question = entry["question"] as? FetchedReference,
              let host = entry["host"] as? FetchedReference else {
            return nil
        }
        self.id = entry.id
        self.game = game
        self.question = question
        self.host = host
    }
    
    static let recordType = "Round"
    
    let id: String
    let game: FetchedReference
    let question: FetchedReference
    let host: FetchedReference
}
