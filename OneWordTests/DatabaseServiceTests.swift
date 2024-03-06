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
        let parent = MockFetchedRecord(name: "Test")
        
        let childRecords: [MockFetchedChildRecord]? = try? await sut.childRecords(of: parent)
        
        let databaseRecordsCalls = database.messages.filter { $0 == .records }
        XCTAssertEqual(databaseRecordsCalls, [.records])
        XCTAssertNotNil(childRecords)
    }
    
    func test_childRecords_returnsEmptyArrayIfNoChildRecordsInDatabase() async throws {
        let (sut, database) = makeSUT(recordInDatabase: false)
        let parent = MockFetchedRecord(name: "Test")

        let childRecords: [MockFetchedChildRecord] = try await sut.childRecords(of: parent)
        
        XCTAssertEqual(0, childRecords.count)
        let databaseRecordsCalls = database.messages.filter { $0 == .records }
        XCTAssertEqual(databaseRecordsCalls, [.records])
    }
    
    func test_childRecords_throwsIfNotConnectedToDatabase() async {
        let (sut, _) = makeSUT(connectedToDatabase: false)
        let parent = MockFetchedRecord(name: "Test")

        await assertDoesThrow(test: {
            let _: [MockFetchedChildRecord] = try await sut.childRecords(of: parent)
        }, throws: DatabaseServiceError.couldNotGetChildrenFromDatabase)
    }
    
    func test_fetchManyToManyRecords_returnsRecordsOnSuccess() async throws {
        let (sut, database) = makeSUT()
        let manyToMany = MockFetchedRecord(name: "test")
        
        let records = try await sut.fetchManyToManyRecords(from: manyToMany, withIntermediary: MockFetchedTwoParentChildRecord.self)
        
        XCTAssertNotEqual(records.count, 0)
        let databaseRecordsCalls = database.messages.filter { $0 == .records }
        let databaseRecordsFromReferencesCalls = database.messages.filter { $0 == .recordsFromReferences }
        XCTAssertEqual(databaseRecordsCalls.count, 1)
        XCTAssertEqual(databaseRecordsFromReferencesCalls.count, 1)
    }
    
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
                         savedRecordToDatabase: Bool = true) -> (DatabaseService, MockDatabase) {
        let container = MockCloudContainer(recordInDatabase: recordInDatabase,
                                           fetchedCorrectRecordType:fetchedCorrectRecordType,
                                           connectedToDatabase: connectedToDatabase,
                                           savedRecordToDatabase: savedRecordToDatabase)
        let database = container.public as! MockDatabase
        let sut = DatabaseService(withContainer: container)
        return (sut, database)
    }
}
