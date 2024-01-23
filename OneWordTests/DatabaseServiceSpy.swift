//
//  MockDatabaseService.swift
//  OneWordTests
//
//  Created by Cory Tripathy on 1/22/24.
//

import XCTest
import CloudKit
@testable import OneWord

actor DatabaseServiceSpy: DatabaseServiceProtocol {
    private var genericRecord: CKRecord {
        let ckRecord = CKRecord(recordType: "butts")
        ckRecord["systemUserID"] = "test id"
        ckRecord["name"] = "test name"
        ckRecord["inviteCode"] = "test invite code"
        return ckRecord
    }
    
    func add<Child, SomeRecord>(_ record: Child, withParent parent: SomeRecord) async throws where Child : OneWord.ChildRecord, SomeRecord : OneWord.Record {
        if didAddSuccessfully {
            receivedMessages.append(.add)
        } else {
            throw NSError(domain: "MockDatabaseServiceError", code: 0)
        }
    }
    
    func fetch<SomeRecord>(withID recordID: String) async throws -> SomeRecord where SomeRecord : OneWord.Record {
        if didFetchSuccessfully {
            receivedMessages.append(.fetch)
            return SomeRecord(from: genericRecord)!
        } else {
            throw NSError(domain: "MockDatabaseServiceError", code: 1)
        }
    }
    
    func update<Child, SomeRecord>(_ record: Child, addingParent parent: SomeRecord) async throws where Child : OneWord.ChildRecord, SomeRecord : OneWord.Record {
        if didUpdateSuccessfully {
            receivedMessages.append(.update)
        } else {
            throw NSError(domain: "MockDatabaseServiceError", code: 2)
        }
    }
    
    
    let didAddSuccessfully: Bool
    let didFetchSuccessfully: Bool
    let didUpdateSuccessfully: Bool
        
    var receivedMessages: [Message] = []
    
    enum Message {
        case add, fetch, update
    }
        
    init(
        didAddSuccessfully: Bool = true,
        didFetchSuccessfully: Bool = true,
        didUpdateSuccessfully: Bool = true) {
            self.didAddSuccessfully = didAddSuccessfully
            self.didFetchSuccessfully = didFetchSuccessfully
            self.didUpdateSuccessfully = didUpdateSuccessfully
        }
}
