//
//  CreatableWord.swift
//  CommandLineToolTest
//
//  Created by Cory Tripathy on 1/31/24.
//

struct Word: CreatableRecord {
    enum RecordKeys: String, CaseIterable { case wordDescription, user, round, rank }
    static let recordType = "Word"
    let id: String
    let wordDescription: String
    let rank: Int?
    let user: User
    let round: Round
}

struct FetchedWord: FetchedRecord, ChildRecord {
    typealias Parent = Round
    init?(from entry: Entry) {
        guard let description = entry["wordDescription"] as? String,
              let user = entry["user"] as? FetchedReference,
              let round = entry["round"] as? FetchedReference else {
            return nil
        }
        self.rank = entry["rank"] as? Int
        self.id = entry.id
        self.description = description
        self.user = user
        self.round = round
    }
    
    static let recordType = "Word"
    
    let id: String
    let description: String
    let rank: Int?
    let user: FetchedReference
    let round: FetchedReference
}
