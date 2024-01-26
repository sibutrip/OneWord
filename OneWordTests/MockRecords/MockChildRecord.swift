//
//  MockChildRecord.swift
//  OneWordTests
//
//  Created by Cory Tripathy on 1/26/24.
//

import CloudKit
@testable import OneWord

struct MockChildRecord: ChildRecord {
    
    static let recordType = "MockChildRecord"
    
    init?(from record: CKRecord, with parent: MockRecord?) {
        guard let description = record["description"] as? String else {
            return nil
        }
        self.init(withDescription: description)
        self.id = record.recordID.recordName
    }
    
    var mockRecord: MockRecord?
    
    enum RecordKeys: String, CaseIterable {
        case description, mockRecord
    }
    
    var id: String
    let description: String
    
    init(withDescription description: String) {
        self.id = UUID().uuidString
        self.description = description
    }
    mutating func addingParent(_ parent: MockRecord) {
        self.mockRecord = parent
    }
}
