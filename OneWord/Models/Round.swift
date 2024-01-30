//
//  Round.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/24/24.
//

import CloudKit

struct Round: ChildRecord {
    
    enum RecordKeys: String, CaseIterable {
        case roundNumber, game, questionNumber
    }
    
    static let recordType = "Round"

    var id: String
    var game: GameModel?
    var question: Question {
        Question(atIndex: questionNumber)
    }
    
    private var questionNumber: Int
    
    // MARK: Database Record Keys
    
    let roundNumber: Int
    
    
    // MARK: Initializers
    
    init?(from record: CKRecord, with parent: GameModel?) {
        guard let roundNumber = record["roundNumber"] as? Int,
        let questionNumber = record["questionNumber"] as? Int else {
            return nil
        }
        self.init(roundNumber: roundNumber, questionNumber: questionNumber)
        self.id = record.recordID.recordName
        self.game = parent
    }
    
    init(roundNumber: Int, questionNumber: Int = Int.random(in: 0..<Question.all.count)) {
        self.roundNumber = roundNumber
        self.questionNumber = questionNumber
        self.id = UUID().uuidString
    }
    
    mutating func addingParent(_ parent: GameModel) {
        self.game = parent
    }
}
