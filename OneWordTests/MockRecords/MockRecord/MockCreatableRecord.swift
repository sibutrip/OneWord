//
//  MockCreatableRecord.swift
//  OneWordTests
//
//  Created by Cory Tripathy on 2/16/24.
//

import Foundation
@testable import OneWord

struct MockCreatableRecord: CreatableRecord {
    enum RecordKeys: String, CaseIterable {
        case name
    }
    
    static let recordType = "MockRecord"
    
    let id: String
    let name: String
    init( name: String) {
        self.id = UUID().uuidString
        self.name = name
    }
}
