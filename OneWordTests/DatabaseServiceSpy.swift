//
//  MockDatabaseService.swift
//  OneWordTests
//
//  Created by Cory Tripathy on 1/22/24.
//

import XCTest
@testable import OneWord

actor DatabaseServiceSpy: DatabaseServiceProtocol {
    
    func add<Child, SomeRecord>(_ record: Child, withParent parent: SomeRecord) async throws where Child : OneWord.ChildRecord, SomeRecord : OneWord.Record {
        if didAddToDatabaseSuccessfully {
            receivedMessages.append(.add)
            expectation?.fulfill()
        } else {
            throw NSError(domain: "MockDatabaseServiceError", code: 0)
        }
    }
    
    func fetch<SomeRecord>(withID recordID: String) async throws -> SomeRecord where SomeRecord : OneWord.Record {
        fatalError("not implemented")
    }
    
    func update<Child, SomeRecord>(_ record: Child, addingParent parent: SomeRecord) async throws where Child : OneWord.ChildRecord, SomeRecord : OneWord.Record {
        fatalError("not implemented")
    }
    
    
    var didAddToDatabaseSuccessfully = true
    
    var expectation: XCTestExpectation?
    
    var receivedMessages: [Message] = []
    
    enum Message {
        case add
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
