//
//  LocalUserVMTests.swift
//  OneWordTests
//
//  Created by Cory Tripathy on 3/11/24.
//

import XCTest
@testable import OneWord

final class LocalUserVMTests: XCTestCase {
    typealias LocalUserViewModelError = LocalUserViewModel.LocalUserViewModelError
    func test_fetchUserInfo_fetchesUserAndAssignsWordsAndUserIfInDatabase() async throws {
        let database = DatabaseServiceSpy()
        let sut = LocalUserViewModel(database: database)
        
        try await sut.fetchUserInfo()
        
        XCTAssertNotNil(sut.user)
        XCTAssertNotEqual(sut.words.count, 0)
        let fetchedUserID = await database.recordFromDatabase.id
        XCTAssertEqual(fetchedUserID, sut.user?.id)
        let databaseMessages = await database.receivedMessages
        XCTAssertEqual(databaseMessages, [.recordForValue, .fetchChildRecords])
    }
    
    func test_fetchUserInfo_createsNewUserIfUserNotInDatabase() async throws {
        let database = DatabaseServiceSpy()
        var entryFromDb = await database.recordFromDatabase
        entryFromDb["systemID"] = nil
        await database.setRecordFromDatabase(entryFromDb)
        let sut = LocalUserViewModel(database: database)
        
        try await sut.fetchUserInfo()
        
        XCTAssertNotNil(sut.user)
        XCTAssertNotEqual(sut.words.count, 0)
        let fetchedUserID = await database.recordFromDatabase.id
        XCTAssertNotEqual(fetchedUserID, sut.user?.id)
        let databaseMessages = await database.receivedMessages
        XCTAssertEqual(databaseMessages, [.recordForValue, .fetchChildRecords])
    }
    
    func test_fetchUserInfo_throwsIfCouldNotConnectToAuthenticate() async {
        let database = DatabaseServiceSpy(authenticationStatus: nil)
        let sut = LocalUserViewModel(database: database)
        
        await assertDoesThrow(test: {
            try await sut.fetchUserInfo()
        }, throws: LocalUserViewModelError.couldNotAuthenticate)
    }
    
    func test_fetchUserInfo_throwsIfCouldNotFetchUser() async {
        let database = DatabaseServiceSpy(didFetchSuccessfully: false)
        let sut = LocalUserViewModel(database: database)
        
        await assertDoesThrow(test: {
            try await sut.fetchUserInfo()
        }, throws: LocalUserViewModelError.couldNotFetchUser)
    }
}
    
