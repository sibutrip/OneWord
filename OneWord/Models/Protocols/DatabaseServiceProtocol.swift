//
//  DatabaseServiceProtocol.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/22/24.
//

protocol DatabaseServiceProtocol: Actor {
    func add(_ game: GameModel, withParent parent: User) async throws
}
