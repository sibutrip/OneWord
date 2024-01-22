//
//  CloudKitService.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/22/24.
//

import Foundation

class CloudKitService: DatabaseServiceProtocol {
    func add(_ game: GameModel, withParent parent: User) async throws {
        throw NSError(domain: "Placeholder Error", code: 0)
    }
    required init() { }
}
