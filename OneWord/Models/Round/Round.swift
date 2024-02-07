//
//  CreatableRound.swift
//  CommandLineToolTest
//
//  Created by Cory Tripathy on 1/31/24.
//

struct Round: CreatableRecord {
    enum RecordKeys: String, CaseIterable { case game, question }
    static let recordType = "Round"
    let id: String
    let game: Game
    let question: Question
}
