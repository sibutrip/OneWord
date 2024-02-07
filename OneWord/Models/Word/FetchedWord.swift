//
//  FetchedWord.swift
//  CommandLineToolTest
//
//  Created by Cory Tripathy on 1/31/24.
//

struct FetchedWord: FetchedRecord {
    init?(from record: any DatabaseEntry) {
        guard let description = record["description"] as? String,
              let user = record["user"] as? EntryReference,
              let round = record["round"] as? EntryReference else {
            return nil
        }
        self.id = record.recordName
        self.description = description
        self.user = FetchedReference(from: user)
        self.round = FetchedReference(from: round)
    }
    
    static let recordType = "Word"
    
    let id: String
    let description: String
    let user: FetchedReference
    let round: FetchedReference
}
