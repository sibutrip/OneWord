//
//  OneWordTests.swift
//  OneWordTests
//
//  Created by Cory Tripathy on 1/18/24.
//

import XCTest
@testable import OneWord

final class GameViewModelTests: XCTestCase {
    
    func test_init_setsUserToLocalUser() {
        let localUser = User(name: "Cory")
        let database = DatabaseServiceSpy()
        
        let sut = GameViewModel(withUser: localUser, database: database)
        
        XCTAssertEqual(sut.localUser, localUser)
    }
    
    func test_createGame_addsNewGameToDatabaseWithUserAsParent() async throws {
        let (sut, databaseService) = makeSUT(withDatabaseExpectation: .didAddGameWithParent)
        
        try await sut.createGame()
        
        await fulfillment(of: [databaseService.expectation!], timeout: 0.5)
        let receivedMessages = await databaseService.receivedMessages
        XCTAssertEqual(receivedMessages, [.add])
    }
    
    func test_createGame_assignsGameToViewModelIfCreatedSuccessfully() async throws {
        let (sut, databaseService) = makeSUT(withDatabaseExpectation: .didAddGameWithParent)
        
        try await sut.createGame()
        
        await fulfillment(of: [databaseService.expectation!], timeout: 0.5)
        XCTAssertNotNil(sut.game)
    }
    
    func test_createGame_throwsIfCannotAddGameToDatabase() async throws {
        let (sut, _) = makeSUT(databaseDidAddSuccessfully: false)
                
        await assertDoesThrow {
            try await sut.createGame()
        }
    }
    
    // MARK: Helper Methods
    
    private func makeSUT(
        withDatabaseExpectation expectation: DatabaseServiceExpectation? = nil,
        databaseDidAddSuccessfully: Bool = true) -> (sut: GameViewModel, databaseService: DatabaseServiceSpy) {
            let localUser = User(name: "Cory")
            let database = DatabaseServiceSpy(withExpectation: expectation, didAddToDatabaseSuccessfully: databaseDidAddSuccessfully)
            return (GameViewModel(withUser: localUser, database: database), database)
        }
    
    private func assertDoesThrow(test action: () async throws -> Void) async {
        do {
            try await action()
        } catch {
            XCTAssertTrue(true)
            return
        }
    }
}
