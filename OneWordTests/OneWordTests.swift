//
//  OneWordTests.swift
//  OneWordTests
//
//  Created by Cory Tripathy on 1/18/24.
//

import XCTest
@testable import OneWord

final class GameViewModelTests: XCTestCase {
    typealias DatabaseService = DatabaseServiceProtocol
    typealias GameViewModel = OneWord.GameViewModel<MockDatabaseService>
    
    func test_init_setsUserToLocalUser() {
        let localUser = User(name: "Cory")
        let database = MockDatabaseService()
        
        let sut = GameViewModel(withUser: localUser, database: database)
        
        XCTAssertEqual(sut.localUser, localUser)
    }
    
    // Q for tom: how do i test that my sut calls a particular method in its database service? do i pass a copy of it to the SUT from `makeSut()`?
    func test_createGame_addsNewGameToDatabaseWithUserAsParent() async throws {
        let (sut, databaseService) = makeSUT(withExpectation: .didAddGameWithParent)
        
        try await sut.createGame()
        
        await fulfillment(of: [databaseService.expectation!], timeout: 0.5)
        let didAddGameWithParent = await databaseService.didAddGameWithParent
        XCTAssertTrue(didAddGameWithParent)
    }
    
    func test_createGame_throwsIfCannotAddGameToDatabase() async throws {
        let (sut, _) = makeSUT(databaseDidAddSuccessfully: false)
                
        await assertDoesThrow {
            try await sut.createGame()
        }
    }
    
    // MARK: Helper Methods
    
    private func makeSUT(
        withExpectation expectation: DatabaseServiceExpectation? = nil,
        databaseDidAddSuccessfully: Bool = true) -> (sut: GameViewModel, databaseService: MockDatabaseService) {
            let localUser = User(name: "Cory")
            let database = MockDatabaseService(withExpectation: expectation, didAddToDatabaseSuccessfully: databaseDidAddSuccessfully)
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
