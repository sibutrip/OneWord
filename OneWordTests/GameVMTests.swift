//
//  OneWordTests.swift
//  OneWordTests
//
//  Created by Cory Tripathy on 1/18/24.
//

import XCTest
@testable import OneWord

final class GameViewModelTests: XCTestCase {
    typealias GameViewModelError = GameViewModel.GameViewModelError
    
    func test_init_setsUserToLocalUserAndAddsToUsersArray() {
        let localUser = User(withName: "Cory")
        let database = DatabaseServiceSpy()
        
        let sut = GameViewModel(withUser: localUser, database: database)
        
        XCTAssertEqual(sut.localUser, localUser)
        XCTAssertEqual(sut.users, [localUser])
    }
    
    func test_createGame_addsNewGameToDatabaseWithUserAsParent() async throws {
        let (sut, databaseService) = makeSUT()
        
        try await sut.createGame(withGroupName: "Test Group")
        
        let receivedMessages = await databaseService.receivedMessages
        XCTAssertEqual(receivedMessages, [.add])
    }
    
    func test_createGame_assignsGameToViewModelIfCreatedSuccessfully() async throws {
        let (sut, _) = makeSUT()
        
        try await sut.createGame(withGroupName: "Test Group")
        
        XCTAssertNotNil(sut.currentGame)
    }
    
    func test_createGame_throwsIfCannotAddGameToDatabase() async throws {
        let (sut, _) = makeSUT(databaseDidAddSuccessfully: false)
        
        await assertDoesThrow(test: {
            try await sut.createGame(withGroupName: "Test Group")
        }, throws: .couldNotCreateGame)
    }
    
    func test_addUser_addsUserToUsersArrayIfSuccessful() async throws {
        let (sut, database) = makeSUT()
        let game = GameModel(withName: "Test Group")
        sut.currentGame = game
        let userIDToAdd = "Some Unique ID"
        
        try await sut.addUser(withId: userIDToAdd)
        
        XCTAssertEqual(sut.users.count, 2)
        let receivedMessages = await database.receivedMessages
        XCTAssertEqual(receivedMessages, [.fetch, .update])
    }
    
    func test_addUser_throwsIfCurrentGameIsNil() async throws {
        let (sut, _) = makeSUT()
        
        await assertDoesThrow(test: {
            try await sut.addUser(withId: "Some Unique ID")
        }, throws: .noCurrentGame)
    }
    
    func test_addUser_throwsIfUserToAddNotInDatabase() async throws {
        let (sut, _) = makeSUT(databaseDidFetchSuccessfully: false)
        let game = GameModel(withName: "Test Group")
        sut.currentGame = game

        await assertDoesThrow(test: {
            try await sut.addUser(withId: "Some Unique ID")
        }, throws: .userNotFound)
    }
    
    func test_addUser_throwsIfCannotUpdateGameOrNewUserInDatabase() async throws {
        let (sut, _) = makeSUT(databaseDidUpdateSuccessfully: false)
        let game = GameModel(withName: "Test Group")
        sut.currentGame = game

        await assertDoesThrow(test: {
            try await sut.addUser(withId: "Some Unique ID")
        }, throws: .couldNotAddUserToGame)
    }
    
    func test_fetchUsersInGame_populatesUsersFromDatabase() async throws {
        let (sut, database) = makeSUT()
        let game = GameModel(withName: "Test Group")
        sut.currentGame = game
        
        try await sut.fetchUsersInGame()
        
        let expectedUsers = await database.childRecordsFromDatabase.map {
            User(from: $0)!
        }
        XCTAssertEqual(sut.users, expectedUsers)
    }
    
    // MARK: Helper Methods
    
    private func makeSUT(
        databaseDidAddSuccessfully: Bool = true,
        databaseDidFetchSuccessfully: Bool = true,
        databaseDidUpdateSuccessfully: Bool = true,
        databaseDidFetchChildRecordsSuccessfully: Bool = true) -> (sut: GameViewModel, databaseService: DatabaseServiceSpy) {
            let localUser = User(withName: "Cory")
            let database = DatabaseServiceSpy(
                didAddSuccessfully: databaseDidAddSuccessfully,
                didFetchSuccessfully: databaseDidFetchSuccessfully,
                didUpdateSuccessfully: databaseDidUpdateSuccessfully,
                didFetchChildRecordsSuccessfully: databaseDidFetchChildRecordsSuccessfully)
            return (GameViewModel(withUser: localUser, database: database), database)
        }
    
    /// `GameViewModel` methods that throw should always throw a `GameViewModelError` error.
    private func assertDoesThrow(test action: () async throws -> Void, throws expectedError: GameViewModelError) async {
        do {
            try await action()
        } catch let error as GameViewModelError where error == expectedError {
            XCTAssert(true)
            return
        } catch {
            XCTFail("expected \(expectedError) error and got \(error)")
            return
        }
        XCTFail("expected \(expectedError) error but did not throw error")
    }
}
