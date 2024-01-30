//
//  RoundViewModel.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/24/24.
//

import Foundation

class RoundViewModel {
    private let database: DatabaseService
    let currentRound: Round
    var question: Question? { currentRound.question }
    var players: [Player] = []
        
    init(round: Round, database: DatabaseService) {
        self.currentRound = round
        self.database = database
    }
    
    public func fetchRoundInfo() async throws { }
}
