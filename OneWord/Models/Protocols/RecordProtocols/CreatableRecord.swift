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
    var entry: Entry {
        var record = Entry(withID: self.id, recordType: Self.recordType)
        let propertiesMirrored = Mirror(reflecting: self)
        for recordKey in Self.RecordKeys.allCases.compactMap({ $0.rawValue as? String }) {
            // TODO: encode creatable record properties as a fetched reference?
            if let propertyLabel = propertiesMirrored.children.first(where: { label, value in
                guard let label else {
                    return false
                }
                return label == recordKey
            }) {
                record[recordKey] = propertyLabel.value
            }
        }
        return record
    }
}
