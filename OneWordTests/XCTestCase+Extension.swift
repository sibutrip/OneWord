//
//  XCTestCase+Extension.swift
//  OneWordTests
//
//  Created by Cory Tripathy on 1/25/24.
//

import XCTest
@testable import OneWord

extension XCTestCase {
    func assertDoesThrow<ErrorType: Error>(test action: () async throws -> Void, throws expectedError: ErrorType) async {
        do {
            try await action()
        } catch {
            if let receivedError = error as? ErrorType,
               receivedError.localizedDescription == expectedError.localizedDescription {
                XCTAssert(true)
                return
            }
            XCTFail("expected \(expectedError) error and got \(error)")
            return
        }
        XCTFail("expected \(expectedError) error but did not throw error")
    }
}
