//
//  RoundViewModel.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/24/24.
//

class RoundViewModel {
    enum RoundViewModelError: Error {
        case noWordsFound
    }
    private let database: DatabaseServiceProtocol
    let localUser: LocalUser
    let round: Round
    let users: [User]
    var playedWords: [Word] = []
        
    init(localUser: LocalUser, round: Round, users: [User], databaseService: DatabaseServiceProtocol) {
        self.localUser = localUser
        self.round = round
        self.users = users
        self.database = databaseService
    }
    
    func fetchWords() async throws {
        guard let fetchedWords: [FetchedWord] = try? await database.childRecords(of: round) else {
            throw RoundViewModelError.noWordsFound
        }
        let playedWords: [Word] = fetchedWords.compactMap { fetchedWord in
            guard let user = users.first(where: { $0.id == fetchedWord.user.recordName }) else {
                return nil
            }
            return Word.played(id: fetchedWord.id, description: fetchedWord.description, withUser: user, inRound: round, rank: fetchedWord.rank)
        }
        self.playedWords = playedWords
    }
    
    func playWord(_ word: Word) {
        
    }
}
