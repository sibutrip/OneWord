//
//  FetchedReference.swift
//  CommandLineToolTest
//
//  Created by Cory Tripathy on 1/31/24.
//

struct FetchedReference {
    init(from reference: EntryReference) {
        self.id = reference.recordName
    }
    var id: String
}
