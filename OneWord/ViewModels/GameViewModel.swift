//
//  GameViewModel.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/22/24.
//

class GameViewModel {
    
    enum GameViewModelError: Error {
        case couldNotCreateGame, noCurrentGame, userNotFound, couldNotAddUserToGame, couldNotFetchUsers, couldNotCreateRound, couldNotFetchRounds
    }
    
    private let databaseService: DatabaseService
    let localUser: User
    var users = [User]()
    var currentGame: GameModel?
    
    var previousRounds = [Round]()
    var currentRound: Round?
    
    init(withUser user: User, database: DatabaseService) {
        localUser = user
        users.append(user)
        databaseService = database
    }
    
    /// Creates new game and updates database with one-to-many relationship.
    ///
    /// Subsequent added users should also have `Game` as a child record of their `User` record.
    /// - Throws `GameViewModelError.couldNotCreateGame` if `databaseService.add` throws.
    func createGame(withGroupName name: String) async throws {
        let newGame = GameModel(withName: name)
        let userGameRelationship = UserGameRelationship(user: localUser, game: newGame)
        do {
            try await databaseService.add(userGameRelationship, withParent: localUser, andSecondParent: newGame)
            self.currentGame = newGame
        } catch {
            throw GameViewModelError.couldNotCreateGame
        }
    }
    
    /// Adds a user to an existing game.
    /// - Parameter userID: The database-registed ID of a `User`. For CloudKit, this is is taken from the user's id in the `Users` CKRecord.
    ///
    /// - Throws `GameViewModelError.noCurrentGame` if `currentGame` is nil.
    /// - Throws `GameViewModelError.userNotFound` if no user with that ID was found in the database.
    /// - Throws `GameViewModelError.couldNotAddUserToGame` if could not update `Game` and `User` records in the database.
    func addUser(withId userID: String) async throws {
        guard let currentGame else { throw GameViewModelError.noCurrentGame }
        guard let userToAdd: User = (try? await databaseService.fetch(withID: userID)) else {
            throw GameViewModelError.userNotFound
        }
        let userGameRelationship = UserGameRelationship(user: userToAdd, game: currentGame)
        do {
            try await databaseService.add(userGameRelationship, withParent: userToAdd, andSecondParent: currentGame)
            self.users.append(userToAdd)
        } catch {
            throw GameViewModelError.couldNotAddUserToGame
        }
    }
    
    /// - Throws `GameViewModelError.noCurrentGame` if `currentGame` is nil.
    /// - Throws `GameViewModelError.couldNotFetchUsers` if could not fetch users from database.
    func fetchUsersInGame() async throws {
        guard let currentGame else { throw GameViewModelError.noCurrentGame }
        guard let usersInGame: [User] = (try? await databaseService.fetchManyToManyRecords(from: currentGame)) else {
            throw GameViewModelError.couldNotFetchUsers
        }
        self.users = usersInGame
    }
    
    /// - Throws `GameViewModelError.NoCurrentGame` if `currentGame` is nil.
    /// - Throws `GameViewModelError.couldNotCreateRound` if `databaseService.add` throws.
    func startRound() async throws {
        guard let currentGame else { throw GameViewModelError.noCurrentGame }
        let newRound = Round(roundNumber: 1)
        do {
            try await databaseService.add(newRound, withParent: currentGame)
            currentRound = newRound
        } catch {
            throw GameViewModelError.couldNotCreateRound
        }
    }
    
    /// - Throws `GameViewModelError.NoCurrentGame` if `currentGame` is nil.
    /// - Throws `GameViewModelError.couldNotFetchRounds` if could not fetch rounds from database.
    func fetchPreviousRounds() async throws {
        guard let currentGame else { throw GameViewModelError.noCurrentGame }
        guard let previousRounds: [Round] = (try? await databaseService.childRecords(of: currentGame)) else {
            throw GameViewModelError.couldNotFetchRounds
        }
        self.previousRounds = previousRounds
    }
}
