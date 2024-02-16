//
//  FetchedUserGameRelationship.swift
//  CommandLineToolTest
//
//  Created by Cory Tripathy on 1/31/24.
//

struct FetchedUserGameRelationship: FetchedRecord {
    init?(from entry: Entry) {
        guard let user = entry["user"] as? FetchedReference,
              let game = entry["game"] as? FetchedReference else {
            return nil
        }
        self.id = entry.id
        self.user = user
        self.game = game
    }
    
    static let recordType = "Word"
    
    let id: String
    let user: FetchedReference
    let game: FetchedReference
}
