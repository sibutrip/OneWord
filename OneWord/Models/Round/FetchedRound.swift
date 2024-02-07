//
//  FetchedRound.swift
//  CommandLineToolTest
//
//  Created by Cory Tripathy on 1/31/24.
//

struct FetchedRound: FetchedRecord {
    init?(from record: any DatabaseEntry) {
        guard let game = record["game"] as? EntryReference,
              let question = record["question"] as? EntryReference else {
            return nil
        }
        self.id = record.recordName
        self.game = FetchedReference(from: game)
        self.question = FetchedReference(from: question)
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
