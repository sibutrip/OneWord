//
//  LocalUserViewModel.swift
//  OneWord
//
//  Created by Cory Tripathy on 3/11/24.
//

import Foundation

@MainActor
class LocalUserViewModel: ObservableObject {
    enum LocalUserViewModelError: String, Error {
        case couldNotFetchUser, couldNotFetchUsersWords, noAccount, accountRestricted, couldNotDetermineAccountStatus, accountTemporarilyUnavailable, iCloudDriveDisabled, couldNotAuthenticate, couldNotCreateAccount
        var errorTitle: String { return self.rawValue }
    }
    
    private let database: DatabaseServiceProtocol
    @Published var user: User? = nil
    @Published var words: [Word] = []
    var userID: User.ID?
    var localUser: LocalUser? {
        guard let user else { return nil }
        return LocalUser(user: user, words: words)
    }
    
    init(database: DatabaseServiceProtocol) {
        self.database = database
    }
    
    func fetchUserInfo() async throws {
        let userID = try await getUserID()
        self.userID = userID
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
            return
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
    
    #warning("add to tests")
    func createUser(withName name: String) async throws {
        guard let userID else { fatalError() }
        let user = User(name: name, systemID: userID)
        do {
            try await database.save(user)
            self.user = user
        } catch { throw LocalUserViewModelError.couldNotCreateAccount }
    }
    
    // MARK: Helper Methods
    
    private func getUserID() async throws -> User.ID {
        guard let authenticationStatus = try? await database.authenticate() else {
            throw LocalUserViewModelError.couldNotAuthenticate
        }
        switch authenticationStatus {
            #warning("add to tests")
        case .available(let userID):
            return userID
        case .noAccount:
            throw LocalUserViewModelError.noAccount
        case .accountRestricted:
            throw LocalUserViewModelError.accountRestricted
        case .couldNotDetermineAccountStatus:
            throw LocalUserViewModelError.couldNotDetermineAccountStatus
        case .accountTemporarilyUnavailable:
            throw LocalUserViewModelError.accountTemporarilyUnavailable
        case .iCloudDriveDisabled:
            throw LocalUserViewModelError.iCloudDriveDisabled
        }
    }
}
