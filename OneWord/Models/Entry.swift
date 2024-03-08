//
//  Entry.swift
//  CommandLineToolTest
//
//  Created by Cory Tripathy on 1/31/24.
//

import CloudKit

struct Entry {
    typealias FieldKey = String
    typealias ID = String
    
    private var values: [String: Any] = [:]
    
    let id: ID
    let recordType: String
    var fields: [FieldKey] = []
    
    subscript(_ index: String) -> Any? {
        get { values[index] }
        set(newValue) { values[index] = newValue}
    }
    
    func allKeys() -> [String] {
        return values.keys.map { String($0) }
    }
    
    init(withID id: Entry.ID, recordType: String) {
        self.id = id
        self.recordType = recordType
    }
}
