//
//  GameViewModel.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/22/24.
//

class GameViewModel {
    
    enum GameViewModelError: Error {
        case couldNotCreateGame, noCurrentGame, userNotFound, couldNotAddUserToGame, couldNotFetchUsers, couldNotCreateRound, couldNotFetchRounds, couldNotFetchQuestion, noAvailableQuestions
    }
    
    private let databaseService: DatabaseServiceProtocol
    var localUser: User
    var users = [User]()
    var currentGame: Game?
    
    var previousRounds = [Round]()
    var currentRound: Round?
    
    init(withUser user: User, database: DatabaseServiceProtocol) {
        localUser = user
        users.append(user)
        databaseService = database
    }
    
    /// Creates new game and updates database with one-to-many relationship.
    ///
    /// Subsequent added users should also have `Game` as a child record of their `User` record.
    /// - Throws `GameViewModelError.couldNotCreateGame` if `databaseService.add` throws.
    public func createGame(withGroupName groupName: String) async throws {
        let newGame = Game(groupName: groupName)
        let userGameRelationship = UserGameRelationship(user: localUser, game: newGame)
        do {
            try await databaseService.save(newGame)
            try await databaseService.add(userGameRelationship, withParent: localUser, withSecondParent: newGame)
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
    public func addUser(withId userID: String) async throws {
        guard let currentGame else { throw GameViewModelError.noCurrentGame }
        guard let fetchedUser: FetchedUser = (try? await databaseService.fetch(withID: userID)) else {
            throw GameViewModelError.userNotFound
        }
        let userToAdd = User(name: fetchedUser.name, systemID: fetchedUser.systemID)
        let userGameRelationship = UserGameRelationship(user: userToAdd, game: currentGame)
        do {
            let _ = try await databaseService.add(userGameRelationship, withParent: userToAdd, withSecondParent: currentGame)
            self.users.append(userToAdd)
        } catch {
            throw GameViewModelError.couldNotAddUserToGame
        }
    }
    
    /// Replaces `self.users` with all users currently in database.
    /// 
    /// - Throws `GameViewModelError.noCurrentGame` if `currentGame` is nil.
    /// - Throws `GameViewModelError.couldNotFetchUsers` if could not fetch users from database.
    public func fetchUsersInGame() async throws {
        guard let currentGame else { throw GameViewModelError.noCurrentGame }
        guard let fetchedUsers: [FetchedUser] = (try? await databaseService.fetchManyToManyRecords(
            fromSecondParent: currentGame,
            withIntermediary: FetchedUserGameRelationship.self)) else {
            throw GameViewModelError.couldNotFetchUsers
        }
        let users: [User] = fetchedUsers.map { User(id: $0.id, name: $0.name, systemID: $0.systemID) }
        self.users = users
    }
    
    /// - Throws `GameViewModelError.NoCurrentGame` if `currentGame` is nil.
    /// - Throws `GameViewModelError.couldNotFetchRounds` if could not fetch rounds from database.
    public func fetchPreviousRounds() async throws {
        guard let currentGame else { throw GameViewModelError.noCurrentGame }
        guard let fetchedPreviousRounds: [FetchedRound] = (try? await databaseService.childRecords(of: currentGame)) else {
            throw GameViewModelError.couldNotFetchRounds
        }
        var previousRounds = [Round]()
        for previousRound in fetchedPreviousRounds {
            guard let fetchedQuestion: Question = try? await databaseService.fetch(withID: previousRound.question.recordName) else {
                throw GameViewModelError.couldNotFetchQuestion
            }
            previousRounds.append(Round(id: previousRound.id, game: currentGame, question: fetchedQuestion))
        }
        self.previousRounds = previousRounds
    }
    
    /// - Throws `GameViewModelError.NoCurrentGame` if `currentGame` is nil.
    /// - Throws `GameViewModelError.couldNotCreateRound` if `databaseService.add` throws.
    public func startRound() async throws {
        guard let currentGame else { throw GameViewModelError.noCurrentGame }
        let allQuestions: [Question] = try await databaseService.records(forType: Question.self)
        let previousQuestions = Set(previousRounds.map { $0.question })
        let newQuestions: [Question] = allQuestions.filter { !previousQuestions.contains($0) }
        guard let randomQuestion = newQuestions.randomElement() else {
            throw GameViewModelError.noAvailableQuestions
        }
        do {
            let newRound = Round(game: currentGame, question: randomQuestion)
            try await databaseService.add(newRound, withParent: currentGame)
            currentRound = newRound
            previousRounds.append(newRound)
        } catch {
            throw GameViewModelError.couldNotCreateRound
        }
    }

//    /// - Throws `GameViewModelError.couldNotFetchRounds` if unable to make `Round` with `databaseService`
//    public func fetchNewestRound() async throws {
//        guard let currentGame else { throw GameViewModelError.noCurrentGame }
//        guard let newestRound: Round = (try? await databaseService.newestChildRecord(of: currentGame)) else {
//            throw GameViewModelError.couldNotFetchRounds
//        }
//        self.currentRound = newestRound
//    }
}
