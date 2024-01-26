//
//  Round.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/24/24.
//

import CloudKit

final class Round: ChildRecord {
    
    enum RecordKeys: String, CaseIterable {
        case roundNumber, game
    }
    
    static let recordType = "Round"

    var id: String
    var gameModel: GameModel?
    
    
    // MARK: Database Record Keys
    
    let roundNumber: Int
    
    
    // MARK: Initializers
    
    convenience init?(from record: CKRecord, with parent: GameModel?) {
        guard let roundNumber = record["roundNumber"] as? Int else {
            return nil
        }
        self.init(roundNumber: roundNumber)
        self.id = record.recordID.recordName
        self.gameModel = parent
    }
    
    required init(roundNumber: Int) {
        self.roundNumber = roundNumber
        self.id = UUID().uuidString
    }
    
}
