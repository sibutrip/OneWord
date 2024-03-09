//
//  CreatableRound.swift
//  CommandLineToolTest
//
//  Created by Cory Tripathy on 1/31/24.
//

import Foundation

struct Round: CreatableRecord, ChildRecord {
    typealias Parent = Game
    enum RecordKeys: String, CaseIterable { case game, question }
    static let recordType = "Round"
    let id: String
    let game: Game
    let question: Question
    init(id: String = UUID().uuidString, game: Game, question: Question) {
        self.id = id
        self.game = game
        self.question = question
    }
}

struct FetchedRound: FetchedRecord, ChildRecord {
    typealias Parent = Game
    init?(from entry: Entry) {
        guard let game = entry["game"] as? FetchedReference,
              let question = entry["question"] as? FetchedReference else {
            return nil
        }
        self.id = entry.id
        self.game = game
        self.question = question
    }
    
    static let recordType = "Round"
    
    let id: String
    let game: FetchedReference
    let question: FetchedReference
}
