//
//  GameViewModel.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/22/24.
//

class GameViewModel {
    private let databaseService: DatabaseServiceProtocol
    let localUser: User
    
    init(withUser user: User, database: DatabaseServiceProtocol) {
        localUser = user
        databaseService = database
    }
    
    func createGame() async throws {
        let newGame = GameModel()
        try await databaseService.add(newGame, withParent: localUser)
    }
}
