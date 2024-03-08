//
//  MockChildRecord.swift
//  OneWordTests
//
//  Created by Cory Tripathy on 1/26/24.
//

import Foundation
@testable import OneWord

struct MockFetchedChildRecord: FetchedRecord, ChildRecord {
    typealias Parent = MockCreatableRecord
    static let recordType = "MockChildRecord"
    
    enum RecordKeys: String, CaseIterable {
        case name, mockRecord
    }
    
    init?(from entry: OneWord.Entry) {
        guard let name = entry["name"] as? String,
              let mockRecord = entry["mockRecord"] as? FetchedRecord else {
            return nil
        }
        self.name = name
        self.mockRecord = mockRecord
        self.id = entry.id
    }
    
    let mockRecord: FetchedRecord
    let id: String
    let name: String
}
