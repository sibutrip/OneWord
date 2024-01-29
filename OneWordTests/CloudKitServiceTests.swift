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
    typealias CloudKitServiceError = CloudKitService.CloudKitServiceError
    private let validID = "some valid ID"

    func test_fetch_returnsRecordWithIDFromDatabase() async {
        let container = MockCloudContainer()
        let database = container.public as! MockDatabase
        let sut = CloudKitService(withContainer: container)
        
        let mockRecord: MockRecord? = try? await sut.fetch(withID: validID)
        
        XCTAssertNotNil(mockRecord)
        let databaseMessages = await database.messages
        XCTAssertEqual(databaseMessages, [.record])
    }
    
    func test_fetch_throwsIfRecordNotInDatabase() async {
        let container = MockCloudContainer(recordInDatabase: false)
        let sut = CloudKitService(withContainer: container)
        
        await assertDoesThrow(test: {
            let _: MockRecord = try await sut.fetch(withID: validID)
        }, throws: CloudKitServiceError.recordNotInDatabase)
    }
    
    func test_fetch_throwsIfTriedToMakeRecordWithIncorrectCKRecord() async {
        let container = MockCloudContainer(fetchedCorrectRecordType: false)
        let sut = CloudKitService(withContainer: container)
        
        await assertDoesThrow(test: {
            let _: MockRecord = try await sut.fetch(withID: validID)
        }, throws: CloudKitServiceError.incorrectlyReadingCloudKitData)
    }
    
    func test_addChildWithParent_addsChildAndParentToDatabaseIfRecordsNotInDatabase() async throws {
        let container = MockCloudContainer(recordInDatabase: false) // parent not in database
        let database = container.public as! MockDatabase
        let sut = CloudKitService(withContainer: container)
        let childRecord = MockChildRecord(withDescription: "Test")
        let parentRecord = MockRecord(name: "test")
        
        let uploadedChild: MockChildRecord = try await sut.add(childRecord, withParent: parentRecord)
        
        XCTAssertNotNil(uploadedChild.mockRecord)
        let databaseRecordCalls = database.messages.filter { $0 == .record }
        let databaseSaveCalls = database.messages.filter { $0 == .save }
        XCTAssertEqual(databaseSaveCalls.count, 2)
        XCTAssertEqual(databaseRecordCalls.count, 2)
    }
    
    func test_addChildWithParent_addsChildAndParentToDatabaseIfRecordsInDatabase() async throws {
        let container = MockCloudContainer()
        let database = container.public as! MockDatabase
        let sut = CloudKitService(withContainer: container)
        let childRecord = MockChildRecord(withDescription: "Test")
        let parentRecord = MockRecord(name: "test")
        
        let uploadedChild: MockChildRecord = try await sut.add(childRecord, withParent: parentRecord)
        
        XCTAssertNotNil(uploadedChild.mockRecord)
        let databaseRecordCalls = database.messages.filter { $0 == .record }
        let databaseModifyCalls = database.messages.filter { $0 == .modify }
        XCTAssertEqual(databaseRecordCalls.count, 2)
        XCTAssertEqual(databaseModifyCalls.count, 2)
    }
}
