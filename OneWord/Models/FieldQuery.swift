//
//  FieldQuery.swift
//  OneWord
//
//  Created by Cory Tripathy on 3/12/24.
//

struct FieldQuery {
    let recordType: String
    let field: String
    let value: String
    init<SomeRecord: FetchedRecord>(forValue value: String, inField field: SomeRecord.RecordKeys, forRecordType recordType: SomeRecord.Type) where SomeRecord.RecordKeys.RawValue == String{
        self.field = field.rawValue
        self.recordType = SomeRecord.recordType
        self.value = value
    }
}
