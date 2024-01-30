//
//  Round.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/24/24.
//

import CloudKit

struct Round: ChildRecord {
    
    enum RecordKeys: String, CaseIterable {
        case roundNumber, game, question
    }
    
    static let recordType = "Round"

    var id: String
    var game: GameModel?
    var question: Question?
    
    
    // MARK: Database Record Keys
    
    let roundNumber: Int
    
    
    // MARK: Initializers
    
    init?(from record: CKRecord, with parent: GameModel?) {
        guard let roundNumber = record["roundNumber"] as? Int,
        let questionReference = record["question"] as? CKRecord.Reference else {
            return nil
        }
        self.init(roundNumber: roundNumber)
        self.id = record.recordID.recordName
        self.question = Question(from: questionReference)
        self.game = parent
    }
    
    init(roundNumber: Int) {
        self.roundNumber = roundNumber
        self.id = UUID().uuidString
    }
    
    mutating func addingParent(_ parent: GameModel) {
        self.game = parent
    }
}
