//
//  MockCloudContainer.swift
//  OneWordTests
//
//  Created by Cory Tripathy on 1/25/24.
//

@testable import OneWord
import CloudKit

class MockCloudContainer: CloudContainer {
    func userRecordID() async throws -> CKRecord.ID {
        return .init(recordName: UUID().uuidString)
    }
    
    func accountStatus() async throws -> CKAccountStatus {
        return .available
    }
    
    let `public`: Database
    init() {
        self.public = MockDatabase()
    }
}
