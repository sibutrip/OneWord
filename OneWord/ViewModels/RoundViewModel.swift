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
    let round: Round
    let users: [User]
    var words: [Word] = []
        
    init(round: Round, users: [User], databaseService: DatabaseServiceProtocol) {
        self.round = round
        self.users = users
        self.database = databaseService
    }
    
    func fetchWords() async throws {
        guard let fetchedWords: [FetchedWord] = try? await database.childRecords(of: round) else {
            throw RoundViewModelError.noWordsFound
        }
        let words: [Word] = fetchedWords.compactMap { fetchedWord in
            guard let user = users.first(where: { $0.id == fetchedWord.user.recordName }) else {
                return nil
            }
            return Word(id: fetchedWord.id, wordDescription: fetchedWord.description, rank: fetchedWord.rank, user: user, round: round)
        }
        self.words = words
    }
}
