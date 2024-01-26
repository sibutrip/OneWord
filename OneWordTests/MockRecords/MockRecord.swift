//
//  MockRecord.swift
//  OneWordTests
//
//  Created by Cory Tripathy on 1/25/24.
//

@testable import OneWord
import CloudKit

struct MockRecord: Record {
    enum RecordKeys: String, CaseIterable {
        case name
    }
    
    static let recordType = "MockRecord"
    
    var id: String
    
    
    // MARK: Database Record Keys
    
    let name: String
    
    
    // MARK: Initializers

    init?(from record: CKRecord) {
        guard let name = record["name"] as? String else {
            return nil
        }
        self.init(name: name)
        self.id = record.recordID.recordName
    }
    
    init(name: String) {
        self.name = name
        self.id = UUID().uuidString
    }
}
