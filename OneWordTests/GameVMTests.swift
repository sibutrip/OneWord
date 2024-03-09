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
    
    func test_init_setsUserToUsersArray() {
        let localUser = User(name: "Cory", systemID: UUID().uuidString)
        let database = DatabaseServiceSpy()
        
        let sut = GameViewModel(withUser: localUser, database: database)
        
        XCTAssertEqual(sut.users.map { $0.id }, [localUser.id])
    }
    
    func test_createGame_addsNewGameToDatabaseWithUserAsParent() async throws {
        let (sut, databaseService) = makeSUT()
        
        try await sut.createGame(withGroupName: "Test Group")
        
        XCTAssertNotNil(sut.currentGame)
        let receivedMessages = await databaseService.receivedMessages
        XCTAssertEqual(receivedMessages, [.save, .add])
    }
    
    func test_createGame_throwsIfCannotAddGameToDatabase() async {
        let (sut, _) = makeSUT(databaseDidAddSuccessfully: false)
        
        await assertDoesThrow(test: {
            try await sut.createGame(withGroupName: "Test Group")
        }, throws: GameViewModelError.couldNotCreateGame)
        XCTAssertNil(sut.currentGame)
    }
    
    func test_addUser_addsUserToUsersArrayIfSuccessful() async throws {
        let (sut, database) = makeSUT()
        let game = Game(groupName: "Test Group")
        sut.currentGame = game
        let userIDToAdd = "Some Unique ID"
        
        try await sut.addUser(withId: userIDToAdd)
        
        XCTAssertEqual(sut.users.count, 2)
        let receivedMessages = await database.receivedMessages
        XCTAssertEqual(receivedMessages, [.fetch, .add])
    }
    
    func test_addUser_throwsIfCurrentGameIsNil() async {
        let (sut, _) = makeSUT()
        
        await assertDoesThrow(test: {
            try await sut.addUser(withId: "Some Unique ID")
        }, throws: GameViewModelError.noCurrentGame)
    }
    
    func test_addUser_throwsIfUserToAddNotInDatabase() async {
        let (sut, _) = makeSUT(databaseDidFetchSuccessfully: false)
        let game = Game(groupName: "Test Group")
        sut.currentGame = game
        
        await assertDoesThrow(test: {
            try await sut.addUser(withId: "Some Unique ID")
        }, throws: GameViewModelError.userNotFound)
    }
    
    func test_addUser_throwsIfCannotUpdateGameOrNewUserInDatabase() async {
        let (sut, _) = makeSUT(databaseDidAddSuccessfully: false)
        let game = Game(groupName: "Test Group")
        sut.currentGame = game
        
        await assertDoesThrow(test: {
            try await sut.addUser(withId: "Some Unique ID")
        }, throws: GameViewModelError.couldNotAddUserToGame)
    }
    
    func test_fetchUsersInGame_populatesUsersFromDatabase() async throws {
        let (sut, database) = makeSUT()
        let game = Game(groupName: "Test Group")
        sut.currentGame = game
        
        try await sut.fetchUsersInGame()
        
        XCTAssertEqual(sut.users.count, 1)
        // user should NOT be the local user. but the user from db
        XCTAssertNotEqual(sut.users.first!.id, sut.localUser.id)
        let receivedMessages = await database.receivedMessages
        XCTAssertEqual(receivedMessages, [.fetchManyToMany])
    }
    
    func test_fetchUsersInGame_throwsIfCurrentGameIsNil() async {
        let (sut, _) = makeSUT()
        
        await assertDoesThrow(test: {
            try await sut.fetchUsersInGame()
        }, throws: GameViewModelError.noCurrentGame)
    }
    
    func test_fetchUsersInGame_throwsIfCannotFetchFromDatabase() async {
        let (sut, _) = makeSUT(databaseDidFetchChildRecordsSuccessfully: false)
        let game = Game(groupName: "Test Group")
        sut.currentGame = game
        
        await assertDoesThrow(test: {
            try await sut.fetchUsersInGame()
        }, throws: GameViewModelError.couldNotFetchUsers)
    }
    
    func test_fetchPreviousRounds_addsRoundsToPreviousRoundsIfSuccessful() async throws {
        let (sut, database) = makeSUT()
        let game = Game(groupName: "Test Group")
        sut.currentGame = game
        
        try await sut.fetchPreviousRounds()
        
        XCTAssertEqual(sut.previousRounds.count, 1)
        let receivedMessages = await database.receivedMessages
        XCTAssertEqual(receivedMessages, [.fetchChildRecords, .fetch])
    }
    
    func test_fetchPreviousRounds_throwsIfCurrentGameIsNil() async {
        let (sut, _) = makeSUT()
        
        await assertDoesThrow(test: {
            try await sut.fetchPreviousRounds()
        }, throws: GameViewModelError.noCurrentGame)
    }
    
    func test_fetchPreviousRounds_throwsIfCouldNotConnectToDatabase() async {
        let (sut, _) = makeSUT(databaseDidFetchChildRecordsSuccessfully: false)
        let game = Game(groupName: "Test Group")
        sut.currentGame = game
        
        await assertDoesThrow(test: {
            try await sut.fetchPreviousRounds()
        }, throws: GameViewModelError.couldNotFetchRounds)
    }
    
    func test_fetchPreviousRounds_throwsIfCouldNotFetchQuestions() async  {
        func test_fetchPreviousRounds_throwsIfCouldNotConnectToDatabase() async {
            let (sut, _) = makeSUT(databaseDidFetchSuccessfully: false)
            let game = Game(groupName: "Test Group")
            sut.currentGame = game
            
            await assertDoesThrow(test: {
                try await sut.fetchPreviousRounds()
            }, throws: GameViewModelError.couldNotFetchQuestion)
        }
    }
    
    func test_startRound_addsNewRoundAndUploadsToDatabase() async throws {
        let (sut, database) = makeSUT()
        let game = Game(groupName: "Test Group")
        sut.currentGame = game
        
        try await sut.startRound()
        
        XCTAssertNotNil(sut.currentRound)
        let receivedMessages = await database.receivedMessages
        XCTAssertEqual(receivedMessages, [.recordsForType, .add])
    }
    
//    func test_startRound_throwsIfCurrentGameIsNil() async {
//        let (sut, _) = makeSUT()
//        
//        await assertDoesThrow(test: {
//            try await sut.startRound()
//        }, throws: GameViewModelError.noCurrentGame)
//    }
//    
//    func test_startRound_throwsIfCouldNotAddGameToDatabase() async {
//        let (sut, _) = makeSUT(databaseDidAddSuccessfully: false)
//        let game = Game(withName: "Test Group")
//        sut.currentGame = game
//        
//        await assertDoesThrow(test: {
//            try await sut.startRound()
//        }, throws: GameViewModelError.couldNotCreateRound)
//    }
//    
//    func test_fetchNewestRound_assignsNewestRoundToVMIfSuccessful() async throws {
//        let (sut, database) = makeSUT()
//        let game = Game(withName: "Test Group")
//        sut.currentGame = game
//        
//        try await sut.fetchNewestRound()
//        
//        XCTAssertNotNil(sut.currentRound)
//        let receivedMessages = await database.receivedMessages
//        XCTAssertEqual(receivedMessages, [.newestChildRecord])
//        
//    }
//    
//    func test_fetchNewestRound_throwsIfNoGameInDatabase() async {
//        let (sut, _) = makeSUT()
//        
//        await assertDoesThrow(test: {
//            try await sut.fetchNewestRound()
//        }, throws: GameViewModelError.noCurrentGame)
//    }
//    
//    func test_fetchNewestRound_throwsIfCouldNotFetchRounds() async {
//        let (sut, _) = makeSUT(databaseDidFetchChildRecordsSuccessfully: false)
//        let game = Game(withName: "Test Group")
//        sut.currentGame = game
//        
//        await assertDoesThrow(test: {
//            try await sut.fetchNewestRound()
//        }, throws: GameViewModelError.couldNotFetchRounds)
//    }
    
    // MARK: Helper Methods
    
    private func makeSUT(
        databaseDidAddSuccessfully: Bool = true,
        databaseDidFetchSuccessfully: Bool = true,
        databaseDidUpdateSuccessfully: Bool = true,
        databaseDidFetchChildRecordsSuccessfully: Bool = true) -> (sut: GameViewModel, databaseService: DatabaseServiceSpy) {
            let localUser = User(name: "Cory", systemID: UUID().uuidString)
            let database = DatabaseServiceSpy(
                didAddSuccessfully: databaseDidAddSuccessfully,
                didFetchSuccessfully: databaseDidFetchSuccessfully,
                didUpdateSuccessfully: databaseDidUpdateSuccessfully,
                didFetchChildRecordsSuccessfully: databaseDidFetchChildRecordsSuccessfully)
            return (GameViewModel(withUser: localUser, database: database), database)
        }
}
