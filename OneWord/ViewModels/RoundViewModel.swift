//
//  RoundViewModel.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/24/24.
//

import Foundation

@MainActor
class RoundViewModel: ObservableObject {
    enum RoundViewModelError: String, DescribableError {
        case noWordsFound, couldNotPlayWord
        var errorTitle: String { self.rawValue }
    }
    private let database: DatabaseServiceProtocol
    @Published var localUser: LocalUser
    let round: Round
    let users: [User]
    @Published var playedWords: [Word] = []
        
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
    
    func playWord(_ word: Word) async throws {
        guard localUser.words.contains(where: { $0.id == word.id }) else {
            return
        }
        var word = word
        word.round = round
        do {
            #warning("update test for if/else logic")
            if var previousWord = playedWords.first(where: {$0.user.id == localUser.id} ) {
                previousWord.description = word.description
                try await database.update(previousWord)
                localUser.words = localUser.words.filter { $0.id != word.id }
                playedWords = playedWords.map { $0.id == previousWord.id ? previousWord : $0}
            } else {
                try await database.add(word, withSecondParent: round)
                localUser.words = localUser.words.filter { $0.id != word.id }
                playedWords.append(word)
            }
        } catch {
            throw RoundViewModelError.couldNotPlayWord
        }
     }
    
    #warning("add to tests")
    func addWord(_ wordString: String) async throws {
        let newWord = Word.new(description: wordString, withUser: localUser.user)
        localUser.addWord(newWord)
        try await playWord(newWord)
//        objectWillChange.send()
    }
}
