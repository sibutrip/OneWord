//
//  User.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/22/24.
//

import CloudKit

final class User: ChildRecord {
    
    enum RecordKeys: String, CaseIterable {
        case systemUserID, name
    }
    
    static let recordType = "User"
    
    var id: String
    var parent: GameModel?
    
    
    // MARK: Database Record Keys
    
    var systemUserID: String
    var name: String
    
    
    // MARK: Initializers
    
    required init() {
        self.id = UUID().uuidString
        self.name = ""
        self.systemUserID = ""
    }
    
    init?(from record: CKRecord, with parent: GameModel) {
        fatalError("not implemented yet")
    }
    
    convenience init(withName name: String) {
        self.init()
        self.name = name
    }
}
