//
//  MockDatabaseService.swift
//  OneWordTests
//
//  Created by Cory Tripathy on 1/22/24.
//

import XCTest
@testable import OneWord

actor MockDatabaseService: DatabaseServiceProtocol {
    
    var didAddToDatabaseSuccessfully = true
    
    var expectation: XCTestExpectation?
    var didAddGameWithParent = false
    
    func add(_ game: GameModel, withParent parent: User) async throws {
        if didAddToDatabaseSuccessfully {
            didAddGameWithParent = true
            expectation?.fulfill()
        } else {
            throw NSError(domain: "MockDatabaseServiceError", code: 0)
        }
    }
    
    init() { }
    
    init(
        withExpectation expectation: DatabaseServiceExpectation?,
        didAddToDatabaseSuccessfully: Bool) {
            self.didAddToDatabaseSuccessfully = didAddToDatabaseSuccessfully
            self.expectation = expectation?.expectation
        }
}

enum DatabaseServiceExpectation {
    case didAddGameWithParent
    var expectation: XCTestExpectation {
        switch self {
        case .didAddGameWithParent:
            return XCTestExpectation(description: "did add game with parent")
        }
    }
}
