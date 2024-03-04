//
//  FetchedReference.swift
//  CommandLineToolTest
//
//  Created by Cory Tripathy on 1/31/24.
//

struct FetchedReference {
    let recordName: String // ID of the record
    let recordType: String // name of the record, i.e. `User`
    init(recordID: String, recordType: String) {
        self.recordName = recordID
        self.recordType = recordType
    }
}
