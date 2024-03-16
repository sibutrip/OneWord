//
//  CreatableRecord.swift
//  CommandLineToolTest
//
//  Created by Cory Tripathy on 1/31/24.
//

protocol CreatableRecord: Record { }

extension CreatableRecord {
    var entry: Entry {
        var entry = Entry(withID: self.id, recordType: Self.recordType)
        let propertiesMirrored = Mirror(reflecting: self)
        for recordKey in Self.RecordKeys.allCases.map({ $0.rawValue }) {
            let propertyLabel = propertiesMirrored.children.first(where: { label, value in
                guard let label else {
                    return false
                }
                return label.lowercased() == recordKey.lowercased()
            })
            
            if let propertyLabel {
                if let record = propertyLabel.value as? any CreatableRecord {
                    let fetchedReference = FetchedReference(recordID: record.id, recordType: type(of: record).recordType)
                    entry[recordKey] = fetchedReference
                } else {
                    entry[recordKey] = propertyLabel.value
                }
            }
        }
        return entry
    }
}
