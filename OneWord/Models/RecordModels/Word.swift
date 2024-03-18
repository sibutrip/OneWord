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
    enum RecordKeys: String, CaseIterable { case Description, Rank, User, Round }
    static let recordType = "Word"
    let id: String
    var description: String
    let rank: Int?
    let user: User
    var round: Round?
    
    static func new(description: String, withUser user: User) -> Word {
        return Word(id: UUID().uuidString, description: description, rank: nil, user: user, round: nil)
    }
    
    static func played(id: String, description: String, withUser user: User, inRound round: Round, rank: Int?) -> Word {
        return Word(id: id, description: description, rank: rank, user: user, round: round)
    }
    
    private init(id: String, description: String, rank: Int?, user: User, round: Round?) {
        self.id = id
        self.description = description
        self.rank = rank
        self.user = user
        self.round = round
    }
}

struct FetchedWord: FetchedTwoParentsChild {
    enum RecordKeys: String, CaseIterable { case WordDescription, Rank, User, Round }
    typealias FetchedParent = FetchedUser
    typealias FetchedSecondParent = FetchedRound
    typealias Parent = User
    typealias SecondParent = Round
    init?(from entry: Entry) {
        guard let description = entry["Description"] as? String,
            let user = entry["User"] as? FetchedReference else {
            return nil
        }
        let round = entry["Round"] as? FetchedReference
        
        self.rank = entry["Rank"] as? Int
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
