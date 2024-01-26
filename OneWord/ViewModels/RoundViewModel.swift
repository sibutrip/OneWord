//
//  RoundViewModel.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/24/24.
//

import Foundation

class RoundViewModel {
    let currentRound: Round
    var question: Question?
    var players: [Player] = []
        
    init(round: Round) {
        self.currentRound = round
    }
    
    public func fetchRoundInfo() async throws { }
}
