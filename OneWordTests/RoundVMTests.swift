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
        let (sut, database) = await makeSUT()
        
        try await sut.fetchWords()
        
        XCTAssertNotEqual(sut.playedWords.count, 0)
        let databaseMessages = await database.receivedMessages
        XCTAssertEqual(databaseMessages, [.fetchChildRecords])
    }
    
    func test_fetchWords_throwsIfCantFetchWordRecords() async {
        let (sut, _) = await makeSUT(didFetchChildRecordsSuccessfully: false)
        
        await assertDoesThrow(test: {
            try await sut.fetchWords()
        }, throws: RoundViewModelError.noWordsFound)
    }
    
    func test_playWord_updatesWordInDbAndRemovesFromLocalUser() async throws {
        let (sut, database) = await makeSUT()
        let wordToPlay = sut.localUser.words.first!
        
        try await sut.playWord(wordToPlay)
        
        XCTAssertTrue(!sut.localUser.words.contains(where: { $0.id == wordToPlay.id }))
    }
        
    // MARK: Helper Methods
    func makeSUT(didFetchChildRecordsSuccessfully: Bool = true) async -> (RoundViewModel, DatabaseServiceSpy) {
        let game = Game(groupName: "Test game")
        let database = DatabaseServiceSpy()
        // fetch one user this way so that a word's user can match one stored in the array
        let userReference: FetchedReference = await database.recordFromDatabase["user"] as! FetchedReference
        let user = User(id: userReference.recordName, name: "Cory", systemID: UUID().uuidString)
        let words = [
            Word.new(description: "Tomothy Barbados", withUser: user),
            Word.new(description: "Sea Shanty", withUser: user)
        ]
        let localUser = LocalUser(user: user, words: words)
        let questionEntry: Entry = await database.recordFromDatabase
        let question = Question(from: questionEntry)!
        let round = Round(localUser: localUser, game: game, question: question, host: localUser.user)
        let users = [
            localUser.user,
            User(name: "Zoe", systemID: UUID().uuidString),
            User(name: "Tariq", systemID: UUID().uuidString)
        ]
        await database.setDidFetchChildRecordsSuccessfully(to: didFetchChildRecordsSuccessfully)
        let roundVm = RoundViewModel(localUser: localUser, round: round, users: users, databaseService: database)
        return (roundVm, database)
    }
}
