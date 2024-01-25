//
//  User.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/22/24.
//

import CloudKit

final class User: ManyToManyRecord {
    
    typealias RelatedRecord = GameModel
    
    enum RecordKeys: String, CaseIterable {
        case systemUserID, name
    }
    
    static let recordType = "User"
    
    var id: String
    var parent: GameModel?
    
    
    // MARK: Database Record Keys
    
    var systemUserID: String
    let name: String
    
    
    // MARK: Initializers
    
    convenience init?(from record: CKRecord) {
        guard let name = record["name"] as? String,
              let systemUserID = record["systemUserID"] as? String else {
            return nil
        }
        self.init(withName: name)
        self.id = record.recordID.recordName
        self.systemUserID = systemUserID
    }
    
    required init(withName name: String) {
        self.name = name
        self.systemUserID = ""
        self.id = UUID().uuidString
    }
}
