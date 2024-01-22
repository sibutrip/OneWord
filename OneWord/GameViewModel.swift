//
//  GameViewModel.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/22/24.
//

class GameViewModel<DatabaseService: DatabaseServiceProtocol> {
    private let databaseService: DatabaseService
    let localUser: User
    
    init(withUser user: User, database: DatabaseService) {
        localUser = user
        databaseService = DatabaseService()
    }
    
    func createGame() async throws {
        let newGame = GameModel()
        try await databaseService.add(newGame, withParent: localUser)
    }
}
