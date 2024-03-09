//
//  RoundVMTests.swift
//  OneWordTests
//
//  Created by Cory Tripathy on 1/24/24.
//

import XCTest
@testable import OneWord

final class RoundViewModelTests: XCTestCase {
    typealias RoundViewModelError = RoundViewModel.RoundViewModelError
    func test_fetchWords_assignsWordsToViewModel() async throws {
        let sut = await makeSUT()
        
        try await sut.fetchWords()
        
        XCTAssertNotEqual(sut.words.count, 0)
    }
    
    func test_fetchWords_throwsIfCantFetchWordRecords() async {
        let sut = await makeSUT(didFetchChildRecordsSuccessfully: false)
        
        await assertDoesThrow(test: {
            try await sut.fetchWords()
        }, throws: RoundViewModelError.noWordsFound)
    }
    
    // MARK: Helper Methods
    func makeSUT(didFetchChildRecordsSuccessfully: Bool = true) async -> RoundViewModel {
        let game = Game(groupName: "Test game")
        let database = DatabaseServiceSpy()
        // fetch one user this way so that a word's user can match one stored in the array
        let userReference: FetchedReference = await database.recordFromDatabase["user"] as! FetchedReference
        let user = User(id: userReference.recordName, name: "Cory", systemID: UUID().uuidString)
        let question: Question = (try! await database.records(forType: Question.self)).first!
        let round = Round(game: game, question: question, host: user)
        let users = [
            user,
            User(name: "Zoe", systemID: UUID().uuidString),
            User(name: "Tariq", systemID: UUID().uuidString)
        ]
        await database.setDidFetchChildRecordsSuccessfully(to: didFetchChildRecordsSuccessfully)
        let roundVm = RoundViewModel(round: round, users: users, databaseService: database)
        return roundVm
    }
}
