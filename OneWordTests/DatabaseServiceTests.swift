//
//  DatabaseServiceTests.swift
//  OneWordTests
//
//  Created by Cory Tripathy on 1/25/24.
//

import XCTest
@testable import OneWord

final class DatabaseServiceTests: XCTestCase {
    typealias DatabaseServiceError = DatabaseService.DatabaseServiceError
    
    func test_addChildWithParent_addsChildAndParentToDatabase() async throws {
        let (sut, database) = makeSUT()
        let parentRecord = MockCreatableRecord(name: "Test Parent")
        let childRecord = MockCreatableChildRecord(name: "Test Child", parent: parentRecord)

        try await sut.add(childRecord, withParent: parentRecord)
        
        let databaseModifyCalls = database.messages.filter { $0 == .modify }
        let databaseSaveCalls = database.messages.filter { $0 == .save }
        XCTAssertEqual(databaseSaveCalls.count, 1)
        XCTAssertEqual(databaseModifyCalls.count, 1)
    }
    func test_addChildWithParent_throwsIfParentRecordNotInDatabase() async {
        let (sut, database) = makeSUT(recordInDatabase: false)
        let parentRecord = MockCreatableRecord(name: "Test Parent")
        let childRecord = MockCreatableChildRecord(name: "Test Child", parent: parentRecord)
        
        await assertDoesThrow(test: {
            try await sut.add(childRecord, withParent: parentRecord)
        }, throws: DatabaseServiceError.couldNotModifyRecord)
        let databaseRecordCalls = database.messages.filter { $0 == .modify }
        XCTAssertEqual(databaseRecordCalls.count, 1)
    }
    
    func test_addChildWithParent_throwsIfCouldNotSaveRecordToDatabase() async {
        let (sut, database) = makeSUT(savedRecordToDatabase: false)
        let parentRecord = MockCreatableRecord(name: "Test Parent")
        let childRecord = MockCreatableChildRecord(name: "Test Child", parent: parentRecord)
        
        await assertDoesThrow(test: {
            try await sut.add(childRecord, withParent: parentRecord)
        }, throws: DatabaseServiceError.couldNotSaveRecord)
        let databaseModifyCalls = database.messages.filter { $0 == .modify }
        let databaseSaveCalls = database.messages.filter { $0 == .save }
        XCTAssertEqual(databaseSaveCalls.count, 1)
        XCTAssertEqual(databaseModifyCalls.count, 1)
    }
    
    func test_addChildWithTwoParents_addsChildAndParentToDatabase() async throws {
        let (sut, database) = makeSUT()
        let firstParent = MockCreatableRecord(name: "First Test Parent")
        let secondParent = MockCreatableRecord(name: "Second Test Parent")
        let childRecord = MockCreatableTwoParentChildRecord(name: "Test Child", parent: firstParent, secondParent: secondParent)

        try await sut.add(childRecord, withParent: firstParent, withSecondParent: secondParent)
        
        let databaseModifyCalls = database.messages.filter { $0 == .modify }
        let databaseSaveCalls = database.messages.filter { $0 == .save }
        XCTAssertEqual(databaseSaveCalls.count, 1)
        XCTAssertEqual(databaseModifyCalls.count, 1)
    }
    func test_addChildWithTwoParents_throwsIfParentRecordNotInDatabase() async {
        let (sut, database) = makeSUT(recordInDatabase: false)
        let firstParent = MockCreatableRecord(name: "First Test Parent")
        let secondParent = MockCreatableRecord(name: "Second Test Parent")
        let childRecord = MockCreatableTwoParentChildRecord(name: "Test Child", parent: firstParent, secondParent: secondParent)

        await assertDoesThrow(test: {
            try await sut.add(childRecord, withParent: firstParent, withSecondParent: secondParent)
        }, throws: DatabaseServiceError.couldNotModifyRecord)
        let databaseRecordCalls = database.messages.filter { $0 == .modify }
        XCTAssertEqual(databaseRecordCalls.count, 1)
    }
    
    func test_addChildWithTwoParents_throwsIfCouldNotSaveRecordToDatabase() async {
        let (sut, database) = makeSUT(savedRecordToDatabase: false)
        let firstParent = MockCreatableRecord(name: "First Test Parent")
        let secondParent = MockCreatableRecord(name: "Second Test Parent")
        let childRecord = MockCreatableTwoParentChildRecord(name: "Test Child", parent: firstParent, secondParent: secondParent)

        await assertDoesThrow(test: {
            try await sut.add(childRecord, withParent: firstParent, withSecondParent: secondParent)
        }, throws: DatabaseServiceError.couldNotSaveRecord)
        let databaseModifyCalls = database.messages.filter { $0 == .modify }
        let databaseSaveCalls = database.messages.filter { $0 == .save }
        XCTAssertEqual(databaseSaveCalls.count, 1)
        XCTAssertEqual(databaseModifyCalls.count, 1)
    }
    
    func test_fetch_returnsRecordFromDatabase() async {
        let (sut, database) = makeSUT()
        
        let fetchedRecord: MockFetchedRecord? = try? await sut.fetch(withID: "Some ID")

        XCTAssertNotNil(fetchedRecord)
        let databaseRecordCalls = database.messages.filter { $0 == .record }
        XCTAssertEqual(databaseRecordCalls, [.record])
    }
    
    func test_fetch_throwsIfFetchedIncorrectRecordFromDatabase() async {
        let (sut, database) = makeSUT(fetchedCorrectRecordType: false)
        
        await assertDoesThrow(test: {
            let _: MockFetchedRecord = try await sut.fetch(withID: "Some ID")
        }, throws: DatabaseServiceError.invalidDataFromDatabase)

        let databaseRecordCalls = database.messages.filter { $0 == .record }
        XCTAssertEqual(databaseRecordCalls, [.record])
    }
    
    func test_childRecords_returnsChildRecordsOnSuccess() async {
        let (sut, database) = makeSUT()
        let parent = MockCreatableRecord(name: "Test")
        
        let childRecords: [MockFetchedChildRecord]? = try? await sut.childRecords(of: parent)
        
        let databaseRecordsCalls = database.messages.filter { $0 == .recordsMatchingQuery }
        XCTAssertEqual(databaseRecordsCalls, [.recordsMatchingQuery])
        XCTAssertNotNil(childRecords)
    }
    
    func test_childRecords_returnsEmptyArrayIfNoChildRecordsInDatabase() async throws {
        let (sut, database) = makeSUT(recordInDatabase: false)
        let parent = MockCreatableRecord(name: "Test")

        let childRecords: [MockFetchedChildRecord] = try await sut.childRecords(of: parent)
        
        XCTAssertEqual(0, childRecords.count)
        let databaseRecordsCalls = database.messages.filter { $0 == .recordsMatchingQuery }
        XCTAssertEqual(databaseRecordsCalls, [.recordsMatchingQuery])
    }
    
    func test_childRecords_throwsIfNotConnectedToDatabase() async {
        let (sut, _) = makeSUT(connectedToDatabase: false)
        let parent = MockCreatableRecord(name: "Test")

        await assertDoesThrow(test: {
            let _: [MockFetchedChildRecord] = try await sut.childRecords(of: parent)
        }, throws: DatabaseServiceError.couldNotGetChildrenFromDatabase)
    }
    
    #warning("add sad paths")
    func test_fetchManyToManyRecordsFromParent_returnsRecordsOnSuccess() async throws {
        let (sut, database) = makeSUT()
        let manyToMany = MockFetchedRecord(name: "test")
        
        let records = try await sut.fetchManyToManyRecords(fromParent: manyToMany, withIntermediary: MockFetchedTwoParentChildRecord.self)
        
        XCTAssertNotEqual(records.count, 0)
        let databaseMessages = database.messages
        XCTAssertEqual(databaseMessages, [.recordsMatchingQuery, .recordsWithID])
    }
    
#warning("add sad paths")
    func test_fetchManyToManyRecordsFromSecondParent_returnsRecordsOnSuccess() async throws {
        let (sut, database) = makeSUT()
        let manyToMany = MockFetchedRecord(name: "test")
        
        let records = try await sut.fetchManyToManyRecords(fromSecondParent: manyToMany, withIntermediary: MockFetchedTwoParentChildRecord.self)
        
        XCTAssertNotEqual(records.count, 0)
        let databaseMessages = database.messages
        XCTAssertEqual(databaseMessages, [.recordsMatchingQuery, .recordsWithID])
    }
    
    func test_save_savesToDatabase() async throws {
        let (sut, database) = makeSUT()
        let newRecord = MockCreatableRecord(name: "test")
        
        try await sut.save(newRecord)
        
        let databaseMessages = database.messages
        XCTAssertEqual(databaseMessages, [.save])
    }
    
    func test_save_throwsIfCannotSave() async {
        let (sut, _) = makeSUT(savedRecordToDatabase: false)
        let newRecord = MockCreatableRecord(name: "test")

        await assertDoesThrow(test: {
            try await sut.save(newRecord)
        }, throws: DatabaseServiceError.couldNotSaveRecord)
    }
    
    func test_records_returnsRecords() async throws {
        let (sut, database) = makeSUT()
        
        let mockRecords: [MockFetchedRecord] = try await sut.records()
        
        XCTAssertNotEqual(mockRecords.count, 0)
        let databaseMessages = database.messages
        XCTAssertEqual(databaseMessages, [.recordsForType])
    }
    
    func test_records_throwsIfCouldntGetRecords() async {
        let (sut, _) = makeSUT(connectedToDatabase: false)
        
        await assertDoesThrow(test: {
            let _: [MockFetchedRecord] = try await sut.records()
        }, throws: DatabaseServiceError.couldNotGetRecords)
    }
    
    func test_authenticate_returnsAvailableAuthenticationStatusWithUserID() async throws {
        let (sut, database) = makeSUT()
        
        let status = try await sut.authenticate()
        switch status {
        case .available(_):
            XCTAssertEqual(database.messages, [.authenticate])
        case .noAccount, .accountRestricted, .couldNotDetermineAccountStatus, .accountTemporarilyUnavailable, .iCloudDriveDisabled:
            XCTFail()
        }
    }
    
    func test_authenticate_returnsNoAccountIfNoAccountFound() async throws {
        let (sut, database) = makeSUT(authenticationStatus: .noAccount)
        
        let status = try await sut.authenticate()
        switch status {
        case .noAccount:
            XCTAssertEqual(database.messages, [.authenticate])
        case .available, .accountRestricted, .couldNotDetermineAccountStatus, .accountTemporarilyUnavailable, .iCloudDriveDisabled:
            XCTFail()
        }
    }
    
    func test_authenticate_returnsAccountRestrictedIfAccountRestricted() async throws {
        let (sut, database) = makeSUT(authenticationStatus: .accountRestricted)
        
        let status = try await sut.authenticate()
        switch status {
        case .accountRestricted:
            XCTAssertEqual(database.messages, [.authenticate])
        case .available, .noAccount, .couldNotDetermineAccountStatus, .accountTemporarilyUnavailable, .iCloudDriveDisabled:
            XCTFail()
        }
    }
    
    func test_authenticate_returnsCouldNotDetermineAccountStatusIfCouldNotDetermineAccountStatus() async throws {
        let (sut, database) = makeSUT(authenticationStatus: .couldNotDetermineAccountStatus)
        
        let status = try await sut.authenticate()
        switch status {
        case .couldNotDetermineAccountStatus:
            XCTAssertEqual(database.messages, [.authenticate])
        case .available, .noAccount, .accountRestricted, .accountTemporarilyUnavailable, .iCloudDriveDisabled:
            XCTFail()
        }
    }
    
    func test_authenticate_returnsAccountTemporarilyUnavailableIfAccountTemporarilyUnavailable() async throws {
        let (sut, database) = makeSUT(authenticationStatus: .accountTemporarilyUnavailable)
        
        let status = try await sut.authenticate()
        switch status {
        case .accountTemporarilyUnavailable:
            XCTAssertEqual(database.messages, [.authenticate])
        case .available, .noAccount, .accountRestricted, .couldNotDetermineAccountStatus, .iCloudDriveDisabled:
            XCTFail()
        }
    }
    
    func test_authenticate_returnsiCloudDriveDisabledIfiCloudDriveDisabled() async throws {
        let (sut, database) = makeSUT(authenticationStatus: .iCloudDriveDisabled)
        
        let status = try await sut.authenticate()
        switch status {
        case .iCloudDriveDisabled:
            XCTAssertEqual(database.messages, [.authenticate])
        case .available, .noAccount, .accountRestricted, .couldNotDetermineAccountStatus, .accountTemporarilyUnavailable:
            XCTFail()
        }
    }
    
    func test_authenticate_throwsIfCannotConnectToDatabase() async throws {
        let (sut, _) = makeSUT(connectedToDatabase: false)
        
        await assertDoesThrow(test: {
            _ = try await sut.authenticate()
        }, throws: DatabaseServiceError.couldNotAuthenticate)
    }
    
    func test_recordForValueInField_returnsRecordIfInDatabase() async throws {
        let (sut, database) = makeSUT()
        
        let record: MockFetchedRecord? = try await sut.record(forValue: "my amazing name", inField: .name)
        
        XCTAssertNotNil(record)
        let databaseMessages = database.messages
        XCTAssertEqual(databaseMessages, [.record])
    }
    
    func test_recordForValueInField_returnsNilIfRecordNotInDatabase() async throws {
        let (sut, database) = makeSUT(recordInDatabase: false)
        
        let record: MockFetchedRecord? = try await sut.record(forValue: "my amazing name", inField: .name)
        
        XCTAssertNil(record)
        let databaseMessages = database.messages
        XCTAssertEqual(databaseMessages, [.record])
    }
    
    func test_recordForValueInField_throwsIfCouldNotConnectToDatabase() async {
        let (sut, _) = makeSUT(connectedToDatabase: false)
        
        await assertDoesThrow(test: {
            let _: MockFetchedRecord? = try await sut.record(forValue: "my amazing name", inField: .name)
        }, throws: DatabaseServiceError.couldNotGetRecords)
    }
    
//case available(User.ID), noAccount, accountRestricted, couldNotDetermineAccountStatus, accountTemporarilyUnavailable, iCloudDriveDisabled
    
//    func test_newestChildRecord_returnsNewestChildRecordIfSuccessful() async throws {
//        let container = MockCloudContainer()
//        let database = container.public as! MockDatabase
//        let sut = DatabaseService(withContainer: container)
//        let parent = MockRecord(name: "test")
//        
//        let _: MockChildRecord = try await sut.newestChildRecord(of: parent)
//        let receivedMessages = database.messages
//        XCTAssertEqual(receivedMessages, [.records])
//    }
    
//    func test_newestChildRecord_throwsIfCouldNotConnectToDatabase() async {
//        let container = MockCloudContainer(connectedToDatabase: false)
//        let sut = DatabaseService(withContainer: container)
//        let parent = MockRecord(name: "test")
//        
//        await assertDoesThrow(test: {
//            let _: MockChildRecord = try await sut.newestChildRecord(of: parent)
//        }, throws: CloudKitServiceError.couldNotConnectToDatabase)
//    }
//    
//    func test_newestChildRecord_throwsIfRecordNotInDatabase() async {
//        let container = MockCloudContainer(recordInDatabase: false)
//        let sut = DatabaseService(withContainer: container)
//        let parent = MockRecord(name: "test")
//        
//        await assertDoesThrow(test: {
//            let _: MockChildRecord = try await sut.newestChildRecord(of: parent)
//        }, throws: CloudKitServiceError.recordNotInDatabase)
//    }
//    
//    func test_newestChildRecord_throwsIfInittingChildWithWrongCkRecord() async {
//        let container = MockCloudContainer(fetchedCorrectRecordType: false)
//        let sut = DatabaseService(withContainer: container)
//        let parent = MockRecord(name: "test")
//        
//        await assertDoesThrow(test: {
//            let _: MockChildRecord = try await sut.newestChildRecord(of: parent)
//        }, throws: CloudKitServiceError.incorrectlyReadingCloudKitData)
//    }
    
    // MARK: Helper Methods
    private func makeSUT(recordInDatabase: Bool = true,
                         fetchedCorrectRecordType: Bool = true,
                         connectedToDatabase: Bool = true,
                         savedRecordToDatabase: Bool = true,
                         authenticationStatus: AuthenticationStatus = .available(UUID().uuidString)) -> (DatabaseService, MockDatabase) {
        let database = MockDatabase(recordInDatabase: recordInDatabase,
                                    fetchedCorrectRecordType:fetchedCorrectRecordType,
                                    connectedToDatabase: connectedToDatabase,
                                    savedRecordToDatabase: savedRecordToDatabase,
                                    authenticationStatus: authenticationStatus)
        let sut = DatabaseService(withDatabase: database)
        return (sut, database)
    }
}
