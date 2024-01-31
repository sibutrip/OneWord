//
//  User.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/22/24.
//

import CloudKit

struct User: ManyToManyRecord, RecordFetchedByID {
    
    typealias RelatedRecord = Game
    typealias Child = UserGameRelationship
    
    enum RecordKeys: String, CaseIterable {
        case systemUserID, name
    }
    
    static let recordType = "User"
    
    var id: String
    
    
    // MARK: Database Record Keys
    
    var systemUserID: String?
    var name: String?
    
    
    // MARK: Initializers
    
    init?(from record: CKRecord) {
        guard let name = record["name"] as? String,
              let systemUserID = record["systemUserID"] as? String else {
            return nil
        }
        self.init(withName: name)
        self.id = record.recordID.recordName
        self.systemUserID = systemUserID
    }
    
    init(withName name: String) {
        self.name = name
        self.systemUserID = ""
        self.id = UUID().uuidString
    }
    
    init(from reference: CKRecord.Reference) {
        self.id = reference.recordID.recordName
    }
}
