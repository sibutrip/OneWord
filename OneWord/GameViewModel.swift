//
//  GameViewModel.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/22/24.
//

class GameViewModel {
    
    enum GameViewModelError: Error {
        case couldNotCreateGame, noCurrentGame, userNotFound
    }
    
    private let databaseService: DatabaseServiceProtocol
    let localUser: User
    var currentGame: GameModel?
    
    init(withUser user: User, database: DatabaseServiceProtocol) {
        localUser = user
        databaseService = database
    }
    
    /// Creates new game and updates database with one-to-many relationship.
    ///  
    /// Subsequent added users should also have `Game` as a child record of their `User` record.
    /// Throws `GameViewModelError.couldNotCreateGame` if `databaseService.add` throws.
    func createGame() async throws {
        let newGame = GameModel()
        do {
            try await databaseService.add(newGame, withParent: localUser)
            self.currentGame = newGame
        } catch {
            throw GameViewModelError.couldNotCreateGame
        }
    }
    
//    func addUser(withId userID: String) async throws {
//        let userToAdd = try await databaseService.fetch(fromID: userID)
//    }
}
