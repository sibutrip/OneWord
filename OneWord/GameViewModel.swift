//
//  Game.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/22/24.
//

import Foundation

class GameViewModel {
    private let databaseService: DatabaseService
    var users: [User]
    
    init(withOwner user: User) {
        let game = GameModel()
        databaseService.add(game, withParent: localUser)
    }
}
