//
//  Question.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/25/24.
//

import CloudKit

struct Question: RecordFetchedByID {
    init(from reference: CKRecord.Reference) {
        self.init(withDecription: "")
        self.id = reference.recordID.recordName
    }
    
    init?(from record: CKRecord) {
        guard let description = record["description"] as? String else {
            return nil
        }
        self.init(withDecription: description)
        self.id = record.recordID.recordName
    }
    
    
    enum RecordKeys: String, CaseIterable {
        case description
    }
    
    static let recordType = "Question"

    var id: String
    
    
    // MARK: Database Record Keys
    
    let description: String
    
    
    // MARK: Initializers
    
    init(withDecription description: String) {
        self.description = description
        self.id = UUID().uuidString
    }
}
