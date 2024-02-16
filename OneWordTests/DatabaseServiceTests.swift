//
//  DatabaseServiceTests.swift
//  OneWordTests
//
//  Created by Cory Tripathy on 1/25/24.
//

import XCTest
import CloudKit
@testable import OneWord

final class DatabaseServiceTests: XCTestCase {
    typealias DatabaseServiceError = DatabaseService.DatabaseServiceError
    
    func test_addChildWithParent_addsChildAndParentToDatabase() async throws {
        let container = MockCloudContainer() // parent not in database
        let database = container.public as! MockDatabase
        let sut = DatabaseService(withContainer: container)
        let parentRecord = MockCreatableRecord(name: "Test Parent")
        let childRecord = MockCreatableChildRecord(name: "Test Child", parent: parentRecord)

        try await sut.add(childRecord, withParent: parentRecord)
        
        let databaseModifyCalls = database.messages.filter { $0 == .modify }
        let databaseSaveCalls = database.messages.filter { $0 == .save }
        XCTAssertEqual(databaseSaveCalls.count, 1)
        XCTAssertEqual(databaseModifyCalls.count, 1)
    }
    func test_addChildWithParent_throwsIfParentRecordNotInDatabase() async {
        let container = MockCloudContainer(recordInDatabase: false)
        let database = container.public as! MockDatabase
        let sut = DatabaseService(withContainer: container)
        let parentRecord = MockCreatableRecord(name: "Test Parent")
        let childRecord = MockCreatableChildRecord(name: "Test Child", parent: parentRecord)
        
        await assertDoesThrow(test: {
            try await sut.add(childRecord, withParent: parentRecord)
        }, throws: DatabaseServiceError.couldNotModifyRecord)
        let databaseRecordCalls = database.messages.filter { $0 == .modify }
        XCTAssertEqual(databaseRecordCalls.count, 1)
    }
    
    func test_addChildWithParent_throwsIfCouldNotSaveRecordToDatabase() async {
        let container = MockCloudContainer(savedRecordToDatabase: false)
        let database = container.public as! MockDatabase
        let sut = DatabaseService(withContainer: container)
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
        let container = MockCloudContainer() // parent not in database
        let database = container.public as! MockDatabase
        let sut = DatabaseService(withContainer: container)
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
        let container = MockCloudContainer(recordInDatabase: false)
        let database = container.public as! MockDatabase
        let sut = DatabaseService(withContainer: container)
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
        let container = MockCloudContainer(savedRecordToDatabase: false)
        let database = container.public as! MockDatabase
        let sut = DatabaseService(withContainer: container)
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
    
    func test_fetch_returnsRecordFromDatabase() async throws {
        let container = MockCloudContainer()
        let database = container.public as! MockDatabase
        let sut = DatabaseService(withContainer: container)
        
        let fetchedRecord: MockFetchedRecord? = try? await sut.fetch(withID: "Some ID")

        XCTAssertNotNil(fetchedRecord)
        let databaseRecordCalls = database.messages.filter { $0 == .record }
        XCTAssertEqual(databaseRecordCalls, [.record])
    }
    
    func test_fetch_throwsIfFetchedIncorrectRecordFromDatabase() async {
        let container = MockCloudContainer(fetchedCorrectRecordType: false)
        let database = container.public as! MockDatabase
        let sut = DatabaseService(withContainer: container)
        
        await assertDoesThrow(test: {
            let _: MockFetchedRecord = try await sut.fetch(withID: "Some ID")
        }, throws: DatabaseServiceError.invalidDataFromDatabase)

        let databaseRecordCalls = database.messages.filter { $0 == .record }
        XCTAssertEqual(databaseRecordCalls, [.record])
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
}
