//
//  MockRecord.swift
//  OneWordTests
//
//  Created by Cory Tripathy on 1/25/24.
//

@testable import OneWord
import Foundation

struct MockFetchedRecord: FetchedRecord {
    
    enum RecordKeys: String, CaseIterable {
        case name
    }
    
    static let recordType = "MockRecord"
    
    var id: String
    
    
    // MARK: Database Record Keys
    
    let name: String
    
    
    // MARK: Initializers
    
    init?(from entry: OneWord.Entry) {
        guard let name = entry["name"] as? String else {
            return nil
        }
        self.name = name
        self.id = entry.id
    }
    
    init(name: String) {
        self.name = name
        self.id = UUID().uuidString
    }
}
