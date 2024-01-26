//
//  ChildRecord.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/23/24.
//

import CloudKit

protocol ChildRecord: Record {
    associatedtype Parent = Record
            
    init?(from record: CKRecord, with parent: Parent?)
}

extension ChildRecord {
    init?(from record: CKRecord) {
        self.init(from: record, with: nil)
    }
}
