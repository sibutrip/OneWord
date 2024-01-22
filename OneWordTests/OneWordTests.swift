//
//  OneWordTests.swift
//  OneWordTests
//
//  Created by Cory Tripathy on 1/18/24.
//

import XCTest
@testable import OneWord

final class GameViewModelTests: XCTestCase {
    func test_init_setsUserToLocalUser() {
        let localUser = User(name: "Cory")
        
        let sut = GameViewModel(withUser: localUser)
        
        XCTAssertEqual(sut.localUser, localUser)
    }
    func test_createGame_addsNewGameToDatabaseWithUserAsParent() { }
}
