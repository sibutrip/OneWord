//
//  FetchedPlayer.swift
//  CommandLineToolTest
//
//  Created by Cory Tripathy on 1/31/24.
//

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
