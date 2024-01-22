//
//  MockDatabaseService.swift
//  OneWordTests
//
//  Created by Cory Tripathy on 1/22/24.
//

import XCTest
@testable import OneWord

class MockDatabaseService: DatabaseServiceProtocol {
    
    var expectation: XCTestExpectation?
    
    var didAddGameWithParent = false
    var didAddGameWithParentCallback: (() -> Void)?
    func add(_ game: GameModel, withParent parent: User) async {
        didAddGameWithParent = true
        didAddGameWithParentCallback?()
    }
    required init() { }
    
    convenience init(withExpectation expectation: DatabaseServiceExpectation?) {
        self.init()
        guard let expectation else { return }
        self.expectation = expectation.expectation
        switch expectation {
        case .didAddGameWithParent:
            self.didAddGameWithParentCallback = expectation.expectation.fulfill
        }
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
