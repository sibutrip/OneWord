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

struct FetchedPlayer: FetchedRecord {
    init?(from entry: Entry) {
        guard let user = entry["user"] as? FetchedReference,
              let round = entry["round"] as? FetchedReference,
              let rank = entry["rank"] as? Int,
              let isHost = entry["isHost"] as? Bool else {
            return nil
        }
        self.id = entry.id
        self.user = user
        self.round = round
        self.rank = rank
        self.isHost = isHost
    }
    
    static let recordType = "Player"
    
    let id: String
    let user: FetchedReference
    let round: FetchedReference
    let rank: Int
    let isHost: Bool
}
