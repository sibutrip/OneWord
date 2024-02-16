//
//  CreatableWord.swift
//  CommandLineToolTest
//
//  Created by Cory Tripathy on 1/31/24.
//

struct Word: CreatableRecord {
    enum RecordKeys: String, CaseIterable { case description, user, round }
    static let recordType = "Word"
    let id: String
    let description: String
    let user: User
    let round: Round
}

struct FetchedWord: FetchedRecord {
    init?(from entry: Entry) {
        guard let description = entry["description"] as? String,
              let user = entry["user"] as? FetchedReference,
              let round = entry["round"] as? FetchedReference else {
            return nil
        }
        self.id = entry.id
        self.description = description
        self.user = user
        self.round = round
    }
    
    static let recordType = "Word"
    
    let id: String
    let description: String
    let user: FetchedReference
    let round: FetchedReference
}
