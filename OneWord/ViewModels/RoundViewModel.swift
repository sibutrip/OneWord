////
////  RoundViewModel.swift
////  OneWord
////
////  Created by Cory Tripathy on 1/24/24.
////
//
//import Foundation
//
//class RoundViewModel {
////    enum RoundViewModelError: Error { }
//    private let databaseService: DatabaseService
//    var currentRound: Round
//    var question: Question? { currentRound.question }
//    var usersInRound: [UserInRound] = []
//        
//    init(round: Round, users: [User], databaseService: DatabaseService) {
//        self.currentRound = round
//        self.databaseService = databaseService
//    }
//    
//    public func fetchRoundInfo() async throws {
//        async let words: [Word] = try await databaseService.childRecords(of: currentRound)
//        async let players: [Player] = try await databaseService.childRecords(of: currentRound)
//        
//    }
//}
