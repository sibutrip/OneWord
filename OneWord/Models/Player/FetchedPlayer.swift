//
//  FetchedPlayer.swift
//  CommandLineToolTest
//
//  Created by Cory Tripathy on 1/31/24.
//

struct FetchedPlayer: FetchedRecord {
    init?(from record: any DatabaseEntry) {
        guard let user = record["user"] as? EntryReference,
              let round = record["round"] as? EntryReference,
              let rank = record["rank"] as? Int,
              let isHost = record["isHost"] as? Bool else {
            return nil
        }
        self.id = record.recordName
        self.user = FetchedReference(from: user)
        self.round = FetchedReference(from: round)
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

struct UserInRound {
    let id: String
    let name: String
    let isHost: Bool
    var rank: Int
    var wordPlayed: String
}

//class RoundViewModel {
//    let game: FetchedGame
//    let roundNumber: Int
//    let question: FetchedQuestion
//    let usersInRound: [UserInRound]
//    
//    let users: [FetchedUser] // i need this user info from gamevm to make the UsersInRound...but i wont have the other details until later
//    
//    func fetchRoundDetails() async throws {
//        
//    }
//}
