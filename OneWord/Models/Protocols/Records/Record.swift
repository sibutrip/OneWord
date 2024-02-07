//
//  Record.swift
//  CommandLineToolTest
//
//  Created by Cory Tripathy on 1/31/24.
//

protocol Record {
    static var recordType: String { get }
    
    var id: String { get }
}

extension Record {
    func reference<Entry: DatabaseEntry>(for type: Entry.Type) -> Entry.Reference {
        return Entry(recordType: Self.recordType, recordID: id).reference
    }
}

