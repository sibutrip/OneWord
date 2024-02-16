//
//  CloudKitServiceTests.swift
//  OneWordTests
//
//  Created by Cory Tripathy on 1/25/24.
//

import XCTest
import CloudKit
@testable import OneWord

final class CloudKitServiceTests: XCTestCase {
    typealias CloudKitServiceError = DatabaseService.CloudKitServiceError
    private let validID = "some valid ID"

//    func test_fetch_returnsRecordWithIDFromDatabase() async {
//        let container = MockCloudContainer()
//        let database = container.public as! MockDatabase
//        let sut = DatabaseService(withContainer: container)
//        
//        let mockRecord: MockFetchedRecord? = try? await sut.fetch(withID: validID)
//        
//        XCTAssertNotNil(mockRecord)
//        let databaseMessages = database.messages
//        XCTAssertEqual(databaseMessages, [.record])
//    }
//    
//    func test_fetch_throwsIfRecordNotInDatabase() async {
//        let container = MockCloudContainer(recordInDatabase: false)
//        let sut = DatabaseService(withContainer: container)
//        
//        await assertDoesThrow(test: {
//            let _: MockRecord = try await sut.fetch(withID: validID)
//        }, throws: CloudKitServiceError.recordNotInDatabase)
//    }
//    
//    func test_fetch_throwsIfTriedToMakeRecordWithIncorrectCKRecord() async {
//        let container = MockCloudContainer(fetchedCorrectRecordType: false)
//        let sut = DatabaseService(withContainer: container)
//        
//        await assertDoesThrow(test: {
//            let _: MockRecord = try await sut.fetch(withID: validID)
//        }, throws: CloudKitServiceError.incorrectlyReadingCloudKitData)
//    }
//    
    func test_addChildWithParent_addsChildAndParentToDatabaseIfRecordsNotInDatabase() async throws {
        let container = MockCloudContainer(recordInDatabase: false) // parent not in database
        let database = container.public as! MockDatabase
        let sut = DatabaseService(withContainer: container)
        let parentRecord = MockCreatableRecord(name: "Test Parent")
        let childRecord = MockCreatableChildRecord(name: "Test Child", parent: parentRecord)

        try await sut.add(childRecord, withParent: parentRecord)
        
        let databaseRecordCalls = database.messages.filter { $0 == .modify }
        let databaseSaveCalls = database.messages.filter { $0 == .save }
        XCTAssertEqual(databaseSaveCalls.count, 1)
        XCTAssertEqual(databaseRecordCalls.count, 1)
    }
//    
//    func test_addChildWithParent_addsChildAndParentToDatabaseIfRecordsInDatabase() async throws {
//        let container = MockCloudContainer()
//        let database = container.public as! MockDatabase
//        let sut = DatabaseService(withContainer: container)
//        let childRecord = MockChildRecord(withName: "Test")
//        let parentRecord = MockRecord(name: "test")
//        
//        let uploadedChild: MockChildRecord = try await sut.add(childRecord, withParent: parentRecord)
//        
//        XCTAssertNotNil(uploadedChild.mockRecord)
//        let databaseRecordCalls = database.messages.filter { $0 == .record }
//        let databaseModifyCalls = database.messages.filter { $0 == .modify }
//        XCTAssertEqual(databaseRecordCalls.count, 2)
//        XCTAssertEqual(databaseModifyCalls.count, 2)
//    }
//    
//    func test_addChildWithParent_throwsIfCannotConnectToDatabase() async {
//        let container = MockCloudContainer(connectedToDatabase: false)
//        let sut = DatabaseService(withContainer: container)
//        let childRecord = MockChildRecord(withName: "Test")
//        let parentRecord = MockRecord(name: "test")
//        
//        await assertDoesThrow(test: {
//        let _: MockChildRecord = try await sut.add(childRecord, withParent: parentRecord)
//        }, throws: CloudKitServiceError.couldNotConnectToDatabase)
//    }
//    
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
//    
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
