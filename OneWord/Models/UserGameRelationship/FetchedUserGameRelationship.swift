//
//  FetchedUserGameRelationship.swift
//  CommandLineToolTest
//
//  Created by Cory Tripathy on 1/31/24.
//

struct FetchedUserGameRelationship: FetchedRecord {
    init?(from record: any DatabaseEntry) {
        guard let user = record["user"] as? EntryReference,
              let game = record["game"] as? EntryReference else {
            return nil
        }
        self.id = record.recordName
        self.user = FetchedReference(from: user)
        self.game = FetchedReference(from: game)
    }
    
    static let recordType = "Word"
    
    let id: String
    let user: FetchedReference
    let game: FetchedReference
}
