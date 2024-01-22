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
        
        await fulfillment(of: [databaseService.expectation!])
        XCTAssertTrue(databaseService.didAddGameWithParent)
    }
    
    // MARK: Helper Methods
    
    private func makeSUT(withExpectation expectation: DatabaseServiceExpectation? = nil) -> (sut: GameViewModel, databaseService: MockDatabaseService) {
        let localUser = User(name: "Cory")
        let database = MockDatabaseService(withExpectation: expectation)
        return (GameViewModel(withUser: localUser, database: database), database)
    }
}
