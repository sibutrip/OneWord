//
//  RoundViewModel.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/24/24.
//

import Foundation

class RoundViewModel {
    enum RoundViewModelError: Error {
        case questionIDNotFound, couldNotFetchQuestion
    }
    private let databaseService: DatabaseService
    var currentRound: Round
    var question: Question? { currentRound.question }
    var players: [Player] = []
        
    init(round: Round, databaseService: DatabaseService) {
        self.currentRound = round
        self.databaseService = databaseService
    }
    
    
    /// - Throws `RoundViewModelError.questionNotFound` if `currentRound.question` is nil. This value should be set when the record is initially fetched in `GameViewModel`
    public func fetchRoundInfo() async throws {
    }
}
