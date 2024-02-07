//
//  DatabaseEntry.swift
//  CommandLineToolTest
//
//  Created by Cory Tripathy on 1/31/24.
//

import CloudKit

protocol DatabaseEntry: AnyObject {
    associatedtype Reference
    
    var reference: Reference { get }
    var recordName: String { get }
    
    subscript(index: String) -> Any? { get set }
    
    init(recordType: String, recordID: String)
}

class CKEntry: CKRecord, DatabaseEntry {
    class Reference: CKRecord.Reference, EntryReference {
        var recordName: String { self.recordID.recordName }
        
        required convenience init(recordID: String) {
            self.init(recordID: CKRecord.ID.init(recordName: recordID), action: .none)
        }
    }
    
    var reference: Reference { Reference(recordID: recordName) }
    var recordName: String {
        return self.recordID.recordName
    }
    
    subscript(index: String) -> Any? {
        get {
            self.value(forKey: index)
        }
        set(newValue) {
            self.setValue(newValue, forKey: index)
        }
    }
    
    convenience required init(recordType: String, recordID: String) {
        self.init(recordType: recordType, recordID: CKRecord.ID(recordName: recordID))
    }
}
