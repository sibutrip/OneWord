//
//  LocalUserVMTests.swift
//  OneWordTests
//
//  Created by Cory Tripathy on 3/11/24.
//

import XCTest
@testable import OneWord

@MainActor
final class LocalUserVMTests: XCTestCase {
    typealias LocalUserViewModelError = LocalUserViewModel.LocalUserViewModelError
    func test_fetchUserInfo_fetchesUserAndAssignsWordsAndUserIfInDatabase() async throws {
        let database = DatabaseServiceSpy()
        let sut = LocalUserViewModel(database: database)
        
        try await sut.fetchUserInfo()
        
        XCTAssertNotNil(sut.user)
        XCTAssertNotNil(sut.userID)
        XCTAssertNotEqual(sut.words.count, 0)
        let fetchedUserID = await database.recordFromDatabase.id
        XCTAssertEqual(fetchedUserID, sut.user?.id)
        let databaseMessages = await database.receivedMessages
        XCTAssertEqual(databaseMessages, [.recordForValue, .fetchChildRecords])
    }
    
    func test_fetchUserInfo_returnsIfUserNotInDatabase() async throws {
        let database = DatabaseServiceSpy()
        var entryFromDb = await database.recordFromDatabase
        entryFromDb["systemID"] = nil
        await database.setRecordFromDatabase(entryFromDb)
        let sut = LocalUserViewModel(database: database)
        
        try await sut.fetchUserInfo()
        
        XCTAssertNil(sut.user)
        XCTAssertNotNil(sut.userID)
        XCTAssertEqual(sut.words.count, 0)
        let databaseMessages = await database.receivedMessages
        XCTAssertEqual(databaseMessages, [.recordForValue])
    }
    
    func test_fetchUserInfo_throwsIfCouldNotConnectToAuthenticate() async {
        let database = DatabaseServiceSpy(authenticationStatus: nil)
        let sut = LocalUserViewModel(database: database)
        
        await assertDoesThrow(test: {
            try await sut.fetchUserInfo()
        }, throws: LocalUserViewModelError.couldNotAuthenticate)
        XCTAssertNil(sut.user)
        XCTAssertNil(sut.userID)
    }
    
    func test_fetchUserInfo_throwsIfCouldNotFetchUser() async {
        let database = DatabaseServiceSpy(didFetchSuccessfully: false)
        let sut = LocalUserViewModel(database: database)
        
        await assertDoesThrow(test: {
            try await sut.fetchUserInfo()
        }, throws: LocalUserViewModelError.couldNotFetchUser)
        XCTAssertNil(sut.user)
        XCTAssertNotNil(sut.userID)
    }
    
    func test_fetchUserInfo_throwsIfCouldNotFetchUsersWords() async {
        let database = DatabaseServiceSpy(didFetchChildRecordsSuccessfully: false)
        let sut = LocalUserViewModel(database: database)
        
        await assertDoesThrow(test: {
            try await sut.fetchUserInfo()
        }, throws: LocalUserViewModelError.couldNotFetchUsersWords)
        XCTAssertNil(sut.user)
        XCTAssertNotNil(sut.userID)
    }
    
    
    func test_createGame_addsNewGameToDatabaseWithUserAsParent() async throws {
        let database = DatabaseServiceSpy()
        let sut = LocalUserViewModel(database: database)
        sut.user = User(name: "Cory", systemID: "My amazing system ID")
        
        let _ = try await sut.newGame(withGroupName: "Test Group")
        
        let receivedMessages = await database.receivedMessages
        XCTAssertEqual(receivedMessages, [.save, .add])
    }
    
    func test_createGame_throwsIfCannotAddGameToDatabase() async {
        let database = DatabaseServiceSpy(didAddSuccessfully: false)
        let sut = LocalUserViewModel(database: database)
        sut.user = User(name: "Cory", systemID: "My amazing system ID")
        
        await assertDoesThrow(test: {
            _ = try await sut.newGame(withGroupName: "Test Group")
        }, throws: LocalUserViewModelError.couldNotCreateGame)
    }
    
    func test_createGame_throwsIfNoUser() async {
        let database = DatabaseServiceSpy()
        let sut = LocalUserViewModel(database: database)
        sut.user = nil
        
        await assertDoesThrow(test: {
            _ = try await sut.newGame(withGroupName: "Test Group")
        }, throws: LocalUserViewModelError.couldNotFetchUser)
    }
    
}
    
