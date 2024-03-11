//
//  CreatableWord.swift
//  CommandLineToolTest
//
//  Created by Cory Tripathy on 1/31/24.
//

import Foundation

struct Word: CreatableRecord, TwoParentsChildRecord {
    typealias Parent = User
    typealias SecondParent = Round
    enum RecordKeys: String, CaseIterable { case wordDescription, rank, user, round }
    static let recordType = "Word"
    let id: String
    let wordDescription: String
    let rank: Int?
    let user: User
    let round: Round?
    
    static func new(description: String, withUser user: User) -> Word {
        return Word(id: UUID().uuidString, wordDescription: description, rank: nil, user: user, round: nil)
    }
    
    static func played(id: String, description: String, withUser user: User, inRound round: Round, rank: Int?) -> Word {
        return Word(id: id, wordDescription: description, rank: rank, user: user, round: round)
    }
    
    private init(id: String, wordDescription: String, rank: Int?, user: User, round: Round?) {
        self.id = id
        self.wordDescription = wordDescription
        self.rank = rank
        self.user = user
        self.round = round
    }
}

struct FetchedWord: FetchedTwoParentsChild {
    typealias FetchedParent = FetchedUser
    typealias FetchedSecondParent = FetchedRound
    typealias Parent = User
    typealias SecondParent = Round
    init?(from entry: Entry) {
        guard let description = entry["wordDescription"] as? String,
            let user = entry["user"] as? FetchedReference else {
            return nil
        }
        let round = entry["round"] as? FetchedReference
        
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
    let round: FetchedReference?
    
    var parentReference: FetchedReference? { return user }
    var secondParentReference: FetchedReference? { return round }
}
