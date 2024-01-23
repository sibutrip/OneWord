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
    
    enum Message {
        case add, fetch, update, fetchChildRecords
    }

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
    
    func add<Child, SomeRecord>(_ record: Child, withParent parent: SomeRecord) async throws where Child : ChildRecord, SomeRecord : Record {
        if didAddSuccessfully {
            receivedMessages.append(.add)
        } else {
            throw NSError(domain: "MockDatabaseServiceError", code: 0)
        }
    }
    
    func fetch<SomeRecord>(withID recordID: String) async throws -> SomeRecord where SomeRecord : Record {
        if didFetchSuccessfully {
            receivedMessages.append(.fetch)
            return SomeRecord(from: recordFromDatabase)!
        } else {
            throw NSError(domain: "MockDatabaseServiceError", code: 1)
        }
    }
    
    func update<Child, SomeRecord>(_ record: Child, addingParent parent: SomeRecord) async throws where Child : ChildRecord, SomeRecord : Record {
        if didUpdateSuccessfully {
            receivedMessages.append(.update)
        } else {
            throw NSError(domain: "MockDatabaseServiceError", code: 2)
        }
    }
    
    func childRecords<Child, ParentRecord>(of parent: ParentRecord) async throws -> [Child] where Child : ChildRecord, ParentRecord : Record {
        if didFetchChildRecordsSuccessfully {
            receivedMessages.append(.fetchChildRecords)
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
