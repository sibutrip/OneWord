//
//  GameViewModel.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/22/24.
//

import Foundation

@MainActor
class GameViewModel: ObservableObject {
    
    enum GameViewModelError: String, DescribableError {
        case couldNotCreateGame, noCurrentGame, userNotFound, couldNotAddUserToGame, couldNotFetchUsers, couldNotCreateRound, couldNotFetchRounds, noAvailableQuestions, couldNotFetchRoundDetails, noUsers
        var errorTitle: String { self.rawValue }
    }
    
    private let database: DatabaseServiceProtocol
    let localUser: LocalUser
    let currentGame: Game
    @Published var users = [User]()
    @Published var previousRounds = [Round]()
    @Published var currentRound: Round?
    
    init(withUser localUser: LocalUser, game: Game, database: DatabaseServiceProtocol) {
        self.localUser = localUser
        self.currentGame = game
        self.database = database
        users.append(localUser.user)
    }
    
    /// Adds a user to an existing game.
    /// - Parameter userID: The database-registed ID of a `User`. For CloudKit, this is is taken from the user's id in the `Users` CKRecord.
    ///
    /// - Throws `GameViewModelError.noCurrentGame` if `currentGame` is nil.
    /// - Throws `GameViewModelError.userNotFound` if no user with that ID was found in the database.
    /// - Throws `GameViewModelError.couldNotAddUserToGame` if could not update `Game` and `User` records in the database.
    public func addUser(withId userID: String) async throws {
        guard let fetchedUser: FetchedUser = (try? await database.fetch(withID: userID)) else {
            throw GameViewModelError.userNotFound
        }
        let userToAdd = User(name: fetchedUser.name, systemID: fetchedUser.systemID)
        let userGameRelationship = UserGameRelationship(user: userToAdd, game: currentGame)
        do {
            let _ = try await database.add(userGameRelationship, withParent: userToAdd, withSecondParent: currentGame)
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
        guard let fetchedUsers: [FetchedUser] = (try? await database.fetchManyToManyRecords(
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
        guard let fetchedPreviousRounds: [FetchedRound] = (try? await database.childRecords(of: currentGame)) else {
            throw GameViewModelError.couldNotFetchRounds
        }
        var previousRounds = [Round]()
        for previousRound in fetchedPreviousRounds {
            async let fetchedQuestionTask: Question = try await database.fetch(withID: previousRound.question.recordName)
            async let fetchedUserTask: FetchedUser = try await database.fetch(withID: previousRound.host.recordName)
            guard let (question, fetchedUser) = try? await (fetchedQuestionTask, fetchedUserTask) else {
                throw GameViewModelError.couldNotFetchRoundDetails
            }
            let host = User(id: fetchedUser.id, name: fetchedUser.name, systemID: fetchedUser.systemID)
            previousRounds.append(Round(id: previousRound.id, localUser: localUser, game: currentGame, question: question, host: host))
        }
        self.currentRound = previousRounds.first
        self.previousRounds = previousRounds
    }
    
    /// - Throws `GameViewModelError.NoCurrentGame` if `currentGame` is nil.
    /// - Throws `GameViewModelError.couldNotCreateRound` if `databaseService.add` throws.
    public func startRound() async throws {
        guard let allQuestions: [Question] = try? await database.records() else { fatalError() }
        let previousQuestions = Set(previousRounds.map { $0.question })
        let newQuestions: [Question] = allQuestions.filter { !previousQuestions.contains($0) }
        guard let randomQuestion = newQuestions.randomElement() ?? allQuestions.randomElement() else {
#warning("change tests. originally threw `noAvailableQuestions` error instead of going to all questions.")
            throw GameViewModelError.noAvailableQuestions
        }
        let nextHost = try nextHost()
        do {
            let newRound = Round(localUser: localUser, game: currentGame, question: randomQuestion, host: nextHost)
            try await database.add(newRound, withParent: currentGame)
            currentRound = newRound
            previousRounds.append(newRound)
        } catch {
            throw GameViewModelError.couldNotCreateRound
        }
    }
    
    // MARK: - Helper Methods
    
    /// Gets next host based on 1. who has hosted the least 2. If nobody has hosted, get a random user.
    ///
    /// - Throws `GameViewModelError.noUser` if there are no users in the game.
    private func nextHost() throws -> User {
        let nextHost = previousRounds
            .reduce(into: [User:Int]()) { partialResult, round in
                partialResult[round.host, default: 0] += 1
            }
            .sorted { $0.value > $1.value }
            .last?.key ?? users.randomElement()
        guard let nextHost else {
#warning("add no users error to tests")
            throw GameViewModelError.noUsers
        }
        return nextHost
    }
}
