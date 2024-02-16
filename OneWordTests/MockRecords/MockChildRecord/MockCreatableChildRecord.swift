//
//  MockCreatableChildRecord.swift
//  OneWordTests
//
//  Created by Cory Tripathy on 2/16/24.
//

import Foundation
@testable import OneWord

struct MockCreatableChildRecord: CreatableRecord, ChildRecord {
    typealias Parent = MockCreatableRecord
    enum RecordKeys: String, CaseIterable {
        case parent, name
    }
    
    static let recordType = "MockChildRecord"
    
    let id: String
    let parent: MockCreatableRecord
    let name: String
    
    init(name: String, parent: MockCreatableRecord) {
        self.id = UUID().uuidString
        self.parent = parent
        self.name = name
    }
}
