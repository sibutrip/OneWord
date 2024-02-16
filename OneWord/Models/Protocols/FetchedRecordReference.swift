//
//  FetchedRecordReference.swift
//  CommandLineToolTest
//
//  Created by Cory Tripathy on 1/31/24.
//

//protocol FetchedRecordReference {
//    var recordName: String { get }
//    init(recordID: String)
//}

struct FetchedReference {
    let recordName: String
    init(recordID: String) {
        self.recordName = recordID
    }
}
