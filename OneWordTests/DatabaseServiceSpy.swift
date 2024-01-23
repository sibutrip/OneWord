//
//  MockDatabaseService.swift
//  OneWordTests
//
//  Created by Cory Tripathy on 1/22/24.
//

import XCTest
import CloudKit
@testable import OneWord

actor DatabaseServiceSpy: DatabaseService {
    var recordFromDatabase: CKRecord = {
        let ckRecord = CKRecord(recordType: "TestRecord")
        ckRecord["systemUserID"] = "test id"
        ckRecord["name"] = "test name"
        ckRecord["inviteCode"] = "test invite code"
        return ckRecord
    }()
    
    var childRecordsFromDatabase: [CKRecord] = {
        let ckRecord = CKRecord(recordType: "ChildRecord")
        ckRecord["systemUserID"] = "test id"
        ckRecord["name"] = "test name"
        ckRecord["inviteCode"] = "test invite code"
        return [ckRecord, ckRecord]
    }()
    
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
            return SomeRecord(from: recordFromDatabase)!
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
    
    func childRecords<Child, ParentRecord>(of parent: ParentRecord) async throws -> [Child] where Child : OneWord.ChildRecord, ParentRecord : OneWord.Record {
        if didFetchChildRecordsSuccessfully {
            receivedMessages.append(.add)
            return childRecordsFromDatabase.map { Child(from: $0)! }
        } else {
            throw NSError(domain: "MockDatabaseServiceError", code: 3)
        }
    }
    
    
    let didAddSuccessfully: Bool
    let didFetchSuccessfully: Bool
    let didUpdateSuccessfully: Bool
    let didFetchChildRecordsSuccessfully: Bool
        
    var receivedMessages: [Message] = []
    
    enum Message {
        case add, fetch, update, fetchChildRecords
    }
        
    init(
        didAddSuccessfully: Bool = true,
        didFetchSuccessfully: Bool = true,
        didUpdateSuccessfully: Bool = true,
        didFetchChildRecordsSuccessfully: Bool = true) {
            self.didAddSuccessfully = didAddSuccessfully
            self.didFetchSuccessfully = didFetchSuccessfully
            self.didUpdateSuccessfully = didUpdateSuccessfully
            self.didFetchChildRecordsSuccessfully = didFetchChildRecordsSuccessfully
        }
}
