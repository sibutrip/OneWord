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
        guard let name = record["name"] as? String else {
            return nil
        }
        self.init(withName: name)
        self.id = record.recordID.recordName
    }
    
    var mockRecord: MockRecord?
    
    enum RecordKeys: String, CaseIterable {
        case name, mockRecord
    }
    
    var id: String
    let name: String
    
    init(withName name: String) {
        self.id = UUID().uuidString
        self.name = name
    }
    mutating func addingParent(_ parent: MockRecord) {
        self.mockRecord = parent
    }
}
