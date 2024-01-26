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
    func test_fetch_returnsRecordWithIDFromDatabase() async throws {
        let sut = CloudKitService(withContainer: MockCloudContainer())
        let validID = "some valid ID"
        
        let mockRecord: MockRecord? = try? await sut.fetch(withID: validID)
        
        XCTAssertNotNil(mockRecord)
    }
}
