//
//  RoundVMTests.swift
//  OneWordTests
//
//  Created by Cory Tripathy on 1/24/24.
//

import XCTest
@testable import OneWord

final class RoundViewModelTests: XCTestCase {
    func test_init_assignsRoundToViewModel() async throws {
        let testRound = Round(roundNumber: 1)
        let sut = RoundViewModel(round: testRound)
        
        XCTAssertEqual(sut.currentRound, testRound)
    }
}