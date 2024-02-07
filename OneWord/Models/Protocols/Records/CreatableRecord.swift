//
//  CreatableRecord.swift
//  CommandLineToolTest
//
//  Created by Cory Tripathy on 1/31/24.
//

protocol CreatableRecord: Record {
    associatedtype RecordKeys: RawRepresentable, CaseIterable where RecordKeys.RawValue: StringProtocol
}

extension CreatableRecord {
    func entry<Entry: DatabaseEntry>() -> Entry {
        let record = Entry(recordType: Self.recordType, recordID: id)
        let propertiesMirrored = Mirror(reflecting: self)
        for recordKey in Self.RecordKeys.allCases.compactMap({ $0.rawValue as? String }) {
            if let propertyLabel = propertiesMirrored.children.first(where: { label, value in
                guard let label else {
                    return false
                }
                return label == recordKey
            }) {
                if let propertyAsRecord = propertyLabel.value as? any Record {
                    record[recordKey] = propertyAsRecord.reference(for: Entry.self)
                } else {
                    record[recordKey] = propertyLabel.value
                }
            }
        }
        return record
    }
}
