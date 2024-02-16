//
//  MockCreatableTwoParentChildRecord.swift
//  OneWordTests
//
//  Created by Cory Tripathy on 2/16/24.
//

import Foundation
@testable import OneWord

struct MockCreatableTwoParentChildRecord: TwoParentsChildRecord, CreatableRecord {
    typealias Parent = MockCreatableRecord
    typealias SecondParent = MockCreatableRecord
    enum RecordKeys: String, CaseIterable {
        case parent, secondParent, name
    }
    
    static let recordType = "MockChildRecord"
    
    let id: String
    let parent: MockCreatableRecord
    let secondParent: MockCreatableRecord

    let name: String
    
    init(name: String, parent: MockCreatableRecord, secondParent: MockCreatableRecord) {
        self.id = UUID().uuidString
        self.parent = parent
        self.secondParent = secondParent
        self.name = name
    }
}
