//
//  LocalUserVMTests.swift
//  OneWordTests
//
//  Created by Cory Tripathy on 3/11/24.
//

import XCTest
@testable import OneWord

final class LocalUserVMTests: XCTestCase {
    func test_fetchUserInfo_assignsWordsAndUserToVMOnSuccess() async throws {
        let database = DatabaseServiceSpy()
        let sut = LocalUserViewModel(database: database)
        
        try await sut.fetchUserInfo()
        
        XCTAssertNotNil(sut.user)
        XCTAssertNotEqual(sut.words.count, 0)
    }
}
    
