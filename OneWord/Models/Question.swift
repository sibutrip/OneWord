//
//  Question.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/25/24.
//

import CloudKit

struct Question: ChildRecord {
    
    enum RecordKeys: String, CaseIterable {
        case description, round
    }
    
    static let recordType = "Question"

    var id: String
    
    
    // MARK: Database Record Keys
    
    let description: String
    var round: Round?
    
    
    // MARK: Initializers
    
    init?(from record: CKRecord, with parent: Round?) {
        guard let description = record["description"] as? String else {
            return nil
        }
        self.init(withDecription: description)
        self.id = record.recordID.recordName
        self.round = parent
    }
    
    init(withDecription description: String) {
        self.description = description
        self.id = UUID().uuidString
    }
    mutating func addingParent(_ parent: Round) {
        self.round = parent
    }
}
