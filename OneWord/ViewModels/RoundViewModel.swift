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
    
    public func fetchRoundInfo() async throws {
        #warning("add to tests")
        guard let questionID = currentRound.question?.id else {
            throw RoundViewModelError.questionIDNotFound
        }
        guard let question: Question = (try? await databaseService.fetch(withID: questionID)) else {
            throw RoundViewModelError.couldNotFetchQuestion
        }
        currentRound.question = question
    }
}
