//
//  CreatablePlayer.swift
//  CommandLineToolTest
//
//  Created by Cory Tripathy on 1/31/24.
//

struct Player: CreatableRecord {
    enum RecordKeys: String, CaseIterable { case user, round, rank, isHost }
    static let recordType = "Player"
    let id: String
    let user: User
    let round: Round
}
