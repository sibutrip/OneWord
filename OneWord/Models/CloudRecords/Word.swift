//
//  Word.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/31/24.
//

import CloudKit

struct Word: ChildRecord {
    
    typealias Parent = Round
    
    enum RecordKeys: String, CaseIterable {
        case user, round
    }
    
    static let recordType = "Question"

    var id: String
    
    // MARK: Database Record Keys
    
    var user: User?
    var round: Round?
    
    
    // MARK: Initializers
    
    init?(from record: CKRecord, with parent: Round?) {
        guard let userIdReference = record["user"] as? CKRecord.Reference else {
            return nil
        }
        self.init()
        self.user = User(from: userIdReference)
        self.id = record.recordID.recordName
        self.round = parent
    }
    
    init() {
        self.id = UUID().uuidString
    }
    
    mutating func addingParent(_ parent: Round) {
        self.round = parent
    }
}
