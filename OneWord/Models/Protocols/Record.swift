//
//  Record.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/23/24.
//

import CloudKit

protocol Record: Identifiable, Hashable where ID == String {
    associatedtype RecordKeys: RawRepresentable, CaseIterable where RecordKeys.RawValue: StringProtocol
    
    static var recordType: String { get }
    
    var id: String { get }
    var ckRecord: CKRecord { get }
    
    init?(from record: CKRecord)
}

extension Record {
    var ckRecord: CKRecord {
        let record = CKRecord(recordType: Self.recordType, recordID: CKRecord.ID(recordName: id))
        let propertiesMirrored = Mirror(reflecting: self)
        for recordKey in Self.RecordKeys.allCases.compactMap({ $0.rawValue as? String }) {
            if let propertyLabel = propertiesMirrored.children.first(where: { label, value in
                guard let label = label else {
                    return false
                }
                return label == recordKey
            }) {
                record.setValue(propertyLabel.value, forKey: recordKey)
            }
        }
        return record
    }
    var recordID: CKRecord.ID {
        ckRecord.recordID
    }
    var reference: CKRecord.Reference {
        return CKRecord.Reference(recordID: ckRecord.recordID, action: .none)
    }
}

/// Hashable and Equatable conformance
extension Record {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
