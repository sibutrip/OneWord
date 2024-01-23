//
//  MockDatabaseService.swift
//  OneWordTests
//
//  Created by Cory Tripathy on 1/22/24.
//

import XCTest
@testable import OneWord

actor DatabaseServiceSpy: DatabaseServiceProtocol {
    
    var didAddToDatabaseSuccessfully = true
    
    var expectation: XCTestExpectation?
    
    var receivedMessages: [Message] = []
    
    enum Message {
        case add
    }
    
    func add(_ game: GameModel, withParent parent: User) async throws {
        if didAddToDatabaseSuccessfully {
            receivedMessages.append(.add)
            expectation?.fulfill()
        } else {
            throw NSError(domain: "MockDatabaseServiceError", code: 0)
        }
    }
        
    init(
        withExpectation expectation: DatabaseServiceExpectation? = nil,
        didAddToDatabaseSuccessfully: Bool = true) {
            self.didAddToDatabaseSuccessfully = didAddToDatabaseSuccessfully
            self.expectation = expectation?.expectation
        }
}

/// Expectations called for asynchronous methods that should not throw when tested.
enum DatabaseServiceExpectation {
    case didAddGameWithParent
    var expectation: XCTestExpectation {
        switch self {
        case .didAddGameWithParent:
            return XCTestExpectation(description: "did add game with parent")
        }
    }
}
