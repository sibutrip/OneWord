//
//  FetchedRound.swift
//  CommandLineToolTest
//
//  Created by Cory Tripathy on 1/31/24.
//

struct FetchedRound: FetchedRecord {
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



//struct CloudKitDataLoader: RemoteDataLoader { // abstraction
//    
//}
//
//protocol RemotePlayerLoader {
//    func fetch() async -> Player
//}
//
//
//
//struct RealPlayer {
//    var isHost: Bool
//    var words: [Word]
//}
//
//
//
//struct Game {
//    var remotePlayerLoader: RemotePlayerLoader
//    var player
//    
//    init(remotePlayerLoader: RemotePlayerLoader) async {
//        self.remotePlayerLoader = remotePlayerLoader
//        await remotePlayerLoader.fetch()
//    }
//    
//    
//}
