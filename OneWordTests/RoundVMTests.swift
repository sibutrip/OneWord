//
//  RoundVMTests.swift
//  OneWordTests
//
//  Created by Cory Tripathy on 1/24/24.
//

import XCTest
@testable import OneWord

final class RoundViewModelTests: XCTestCase {
    
    func test_fetchWords_assignsWordsToViewModel() async throws {
        let sut = await makeSUT()
        
        try await sut.fetchWords()
        
        XCTAssertNotEqual(sut.words.count, 0)
    }
    
    // MARK: Helper Methods
    func makeSUT() async -> RoundViewModel {
        let game = Game(groupName: "Test game")
        let database = DatabaseServiceSpy()
        // fetch one user this way so that a word's user can match one stored in the array
        let userReference: FetchedReference = await database.recordFromDatabase["user"] as! FetchedReference
        let user = User(id: userReference.recordName, name: "Cory", systemID: UUID().uuidString)
        let question: Question = (try! await database.records(forType: Question.self)).first!
        let round = Round(game: game, question: question)
        let users = [
            user,
            User(name: "Zoe", systemID: UUID().uuidString),
            User(name: "Tariq", systemID: UUID().uuidString)
        ]
        let roundVm = RoundViewModel(round: round, users: users, host: users.first!, databaseService: database)
        return roundVm
    }
}
