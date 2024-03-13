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
        case couldNotFetchUser, couldNotFetchUsersWords, noAccount, accountRestricted, couldNotDetermineAccountStatus, accountTemporarilyUnavailable, iCloudDriveDisabled, couldNotAuthenticate, couldNotCreateAccount, couldNotCreateGame
        var errorTitle: String { return self.rawValue }
    }
    
    private let database: DatabaseServiceProtocol
    @Published var user: User? = nil
    @Published var words: [Word] = []
    @Published var games: [Game] = []
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
    
#warning("add to tests")
    func fetchGames() async throws {
        guard let user else { fatalError() }
        let fetchedGames: [FetchedGame] = try await database.fetchManyToManyRecords(fromParent: user, withIntermediary: FetchedUserGameRelationship.self)
        let games = fetchedGames.map { Game(id: $0.id, groupName: $0.groupName) }
        self.games = games
    }
    
    /// Creates new game and updates database with one-to-many relationship.
    ///
    /// Subsequent added users should also have `Game` as a child record of their `User` record.
    /// - Throws `GameViewModelError.couldNotCreateGame` if `databaseService.add` throws.
    public func newGame(withGroupName groupName: String) async throws -> Game {
        #warning("add to tests")
        guard let user else { throw LocalUserViewModelError.couldNotFetchUser }
        let newGame = Game(groupName: groupName)
        let userGameRelationship = UserGameRelationship(user: user, game: newGame)
        do {
            try await database.save(newGame)
            try await database.add(userGameRelationship, withParent: user, withSecondParent: newGame)
            return newGame
        } catch {
            throw LocalUserViewModelError.couldNotCreateGame
        }
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
