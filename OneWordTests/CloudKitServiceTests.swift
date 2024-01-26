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
        let sut = CloudKitService(withContainer: MockCloudContainer())
        
        let mockRecord: MockRecord? = try? await sut.fetch(withID: validID)
        
        XCTAssertNotNil(mockRecord)
    }
    
    func test_fetch_throwsIfRecordNotInDatabase() async throws {
        let container = MockCloudContainer(fetchedRecordSuccessfully: false)
        let sut = CloudKitService(withContainer: container)
        
        await assertDoesThrow(test: {
            let _: MockRecord = try await sut.fetch(withID: validID)
        }, throws: CloudKitServiceError.recordNotInDatabase)
    }
}
