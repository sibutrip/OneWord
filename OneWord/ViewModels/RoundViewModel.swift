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
        case noWordsFound, couldNotPlayWord, wordsNotScored
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
    
    #warning("update tests")
    func playWord(_ word: Word) async throws {
        var word = word
        word.round = round
        objectWillChange.send()
        do {

            // if player had already played a word in the round
            if var previousWord = playedWords.first(where: {$0.user.id == localUser.id} ) {
                
                // if player typed in a new word, update it in database
                if localUser.words.count == 0 {
                    previousWord.description = word.description
                    playedWords = playedWords.map { $0.id == previousWord.id ? previousWord : $0 }
                    try await database.update(previousWord)
                } else {
                    previousWord.round = nil
                    localUser.words = localUser.words.map { $0.id == word.id ? previousWord : $0 }
                    playedWords = playedWords.map { $0.id == previousWord.id ? word : $0 }
                    try await database.update(previousWord)
                    try await database.update(word)
                }
            } else {
                localUser.words = localUser.words.filter { $0.id != word.id }
                playedWords.append(word)
                try await database.add(word, withSecondParent: round)
            }
        } catch {
            throw RoundViewModelError.couldNotPlayWord
        }
     }
    
    #warning("add to tests")
    func submitWordScores() async throws {
        guard !playedWords
            .map({$0.rank})
            .contains(where: {$0 == nil}) else { throw RoundViewModelError.wordsNotScored }
        try await withThrowingTaskGroup(of: Void.self) { taskGroup in
            for word in playedWords {
                taskGroup.addTask {
                    try await self.database.update(word)
                }
            }
            for try await _ in taskGroup { }
        }
    }
    
    #warning("add to tests")
    func playNewWord(_ wordString: String) async throws {
        let newWord = Word.new(description: wordString, withUser: localUser.user)
        try await playWord(newWord)
    }
}
