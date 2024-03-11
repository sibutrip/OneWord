//
//  LocalUserViewModel.swift
//  OneWord
//
//  Created by Cory Tripathy on 3/11/24.
//

class LocalUserViewModel {
    private let database: DatabaseServiceProtocol
    var user: User? = nil
    var words: [Word] = []
    var localUser: LocalUser? {
        guard let user else { return nil }
        return LocalUser(user: user, words: words)
    }
    
    init(database: DatabaseServiceProtocol) {
        self.database = database
    }
    
    func fetchUserInfo() async throws {
        let userID = try await database.authenticate()
        let fetchedUser: FetchedUser = try await database.record(forValue: userID, inField: .systemID)
        let user = User(id: fetchedUser.id, name: fetchedUser.name, systemID: fetchedUser.systemID)
        let fetchedWords: [FetchedWord] = try await database.childRecords(of: user)
        let unplayedWords: [Word] = fetchedWords.compactMap { fetchedWord in
            if fetchedWord.round != nil {
                return nil
            }
            return Word.new(description: fetchedWord.description, withUser: user)
        }
        self.words = unplayedWords
        self.user = user
    }
}
