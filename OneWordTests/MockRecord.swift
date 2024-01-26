//
//  MockRecord.swift
//  OneWordTests
//
//  Created by Cory Tripathy on 1/25/24.
//

@testable import OneWord
import CloudKit

final class MockRecord: Record {
    enum RecordKeys: String, CaseIterable {
        case name
    }
    
    static let recordType = "Mock Record"
    
    var id: String
    
    
    // MARK: Database Record Keys
    
    let name: String
    
    
    // MARK: Initializers

    convenience init?(from record: CKRecord) {
        guard let name = record["name"] as? String else {
            return nil
        }
        self.init(name: name)
        self.id = record.recordID.recordName
    }
    
    required init(name: String) {
        self.name = name
        self.id = UUID().uuidString
    }
}
