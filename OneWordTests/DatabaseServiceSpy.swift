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
    func fetch<SomeRecord>(withID recordID: String) async throws -> SomeRecord where SomeRecord : OneWord.Record {
        if didFetchSuccessfully {
            receivedMessages.append(.fetch)
            return SomeRecord(from: recordFromDatabase)!
        } else {
            throw NSError(domain: "MockDatabaseServiceError", code: 3)
        }
    }
    
    func add<Child>(_ record: Child, withParent parent: Child.Parent) async throws -> Child where Child : OneWord.ChildRecord {
        if didAddSuccessfully {
            receivedMessages.append(.add)
            return record
        } else {
            throw NSError(domain: "MockDatabaseServiceError", code: 0)
        }
    }
    
    func add<Child>(_ record: Child, withParent parent: Child.Parent, andSecondParent: Child.SecondParent) async throws -> Child where Child : OneWord.TwoParentsChildRecord {
        if didAddSuccessfully {
            receivedMessages.append(.add)
            return record
        } else {
            throw NSError(domain: "MockDatabaseServiceError", code: 0)
        }
    }
    
    func update<Child>(_ record: Child, addingParent parent: Child.Parent) async throws -> Child where Child : OneWord.ChildRecord {
        if didUpdateSuccessfully {
            receivedMessages.append(.update)
            return record
        } else {
            throw NSError(domain: "MockDatabaseServiceError", code: 2)
        }
    }
    
    func childRecords<Child>(of parent: Child.Parent) async throws -> [Child] where Child : OneWord.ChildRecord {
        if didFetchChildRecordsSuccessfully {
            receivedMessages.append(.fetchChildRecords)
            return childRecordsFromDatabase.map { Child(from: $0)! }
        } else {
            throw NSError(domain: "MockDatabaseServiceError", code: 3)
        }
    }
    
    func fetchManyToManyRecords<FromRecord>(from: FromRecord) async throws -> [FromRecord.RelatedRecord] where FromRecord : OneWord.ManyToManyRecord {
        if didFetchChildRecordsSuccessfully {
            receivedMessages.append(.fetchManyToMany)
            return childRecordsFromDatabase.map { FromRecord.RelatedRecord(from: $0)! }
        } else {
            throw NSError(domain: "MockDatabaseServiceError", code: 3)
        }
    }
    
    
    enum Message {
        case add, fetch, update, fetchChildRecords, fetchManyToMany
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
        ckRecord["roundNumber"] = 1
        return [ckRecord, ckRecord]
    }()
    
    
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
