//
//  LocalUserViewModel.swift
//  OneWord
//
//  Created by Cory Tripathy on 3/11/24.
//

class LocalUserViewModel {
    enum LocalUserViewModelError: Error {
        case couldNotFetchUser, couldNotFetchUsersWords, noAccount, accountRestricted, couldNotDetermineAccountStatus, accountTemporarilyUnavailable, iCloudDriveDisabled
    }
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
        let userID = try await getUserID()
        let fetchedUser: FetchedUser?
        do {
            fetchedUser = try await database.record(forValue: userID, inField: .systemID)
        } catch {
            throw LocalUserViewModelError.couldNotFetchUser
        }
        let user: User
        if let fetchedUser {
            user = User(id: fetchedUser.id, name: fetchedUser.name, systemID: fetchedUser.systemID)
        } else {
            user = User(name: "User inputted Name", systemID: userID)
        }
        
        guard let fetchedWords: [FetchedWord] = try? await database.childRecords(of: user) else {
            throw LocalUserViewModelError.couldNotFetchUsersWords
        }
        let unplayedWords: [Word] = fetchedWords.compactMap { fetchedWord in
            if fetchedWord.round != nil {
                return nil
            }
            return Word.new(description: fetchedWord.description, withUser: user)
        }
        self.words = unplayedWords
        self.user = user
    }
    
    // MARK: Helper Methods
    
    private func getUserID() async throws -> User.ID {
        guard let authenticationStatus = try? await database.authenticate() else {
            throw LocalUserViewModelError.couldNotFetchUser
        }
        switch authenticationStatus {
        case .available(let userID):
            return userID
        case .noAccount:
            fatalError()
        case .accountRestricted:
            fatalError()
        case .couldNotDetermineAccountStatus:
            fatalError()
        case .accountTemporarilyUnavailable:
            fatalError()
        case .iCloudDriveDisabled:
            fatalError()
        }
    }
}
