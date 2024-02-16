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
    func add<SomeRecord>(_ record: SomeRecord, withParent parent: SomeRecord.Parent) async throws where SomeRecord : OneWord.ChildRecord, SomeRecord : OneWord.CreatableRecord, SomeRecord.Parent : OneWord.CreatableRecord {
        if didAddSuccessfully {
            receivedMessages.append(.add)
        } else {
            throw NSError(domain: "MockDatabaseServiceError", code: 0)
        }
    }
    
    func add<SomeRecord>(_ record: SomeRecord, withParent parent: SomeRecord.Parent, withSecondParent secondParent: SomeRecord.SecondParent) async throws where SomeRecord : OneWord.CreatableRecord, SomeRecord : OneWord.TwoParentsChildRecord, SomeRecord.Parent : OneWord.CreatableRecord, SomeRecord.SecondParent : OneWord.CreatableRecord {
        if didAddSuccessfully {
            receivedMessages.append(.add)
        } else {
            throw NSError(domain: "MockDatabaseServiceError", code: 0)
        }
    }
    
    func newestChildRecord<Child>(of parent: Child.Parent) async throws -> Child where Child : OneWord.ChildRecord {
        if didFetchChildRecordsSuccessfully {
            receivedMessages.append(.newestChildRecord)
            fatalError()
//            return Child(from: recordFromDatabase)!
        } else {
            throw NSError(domain: "MockDatabaseServiceError", code: 4)
        }
    }
    
    func fetch<SomeRecord>(withID recordID: String) async throws -> SomeRecord where SomeRecord : OneWord.FetchedRecord {
        if didFetchSuccessfully {
            receivedMessages.append(.fetch)
            return SomeRecord(from: recordFromDatabase)!
        } else {
            throw NSError(domain: "MockDatabaseServiceError", code: 3)
        }
    }
    
    func childRecords<Child>(of parent: Child.Parent) async throws -> [Child] where Child : ChildRecord, Child: FetchedRecord, Child.Parent: FetchedRecord  {
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
        case add, fetch, update, fetchChildRecords, fetchManyToMany, newestChildRecord
    }

    var recordFromDatabase: Entry = {
        var entry = Entry(withID: UUID().uuidString, recordType: "MockRecord")
        entry["systemUserID"] = "test id"
        entry["name"] = "test name"
        entry["inviteCode"] = "test invite code"
        entry["description"] = "description"
        entry["roundNumber"] = 1
        entry["user"] = FetchedReference(recordID: UUID().uuidString)
        entry["round"] = FetchedReference(recordID: UUID().uuidString)
        entry["game"] = FetchedReference(recordID: UUID().uuidString)
        entry["questionNumber"] = 1
        entry["isHost"] = true
        entry["rank"] = 1
        return entry
    }()
    
    var childRecordsFromDatabase: [Entry] = {
        var entry = Entry(withID: UUID().uuidString, recordType: "MockRecord")
        entry["systemUserID"] = "test id"
        entry["name"] = "test name"
        entry["inviteCode"] = "test invite code"
        entry["description"] = "description"
        entry["roundNumber"] = 1
        entry["user"] = FetchedReference(recordID: UUID().uuidString)
        entry["round"] = FetchedReference(recordID: UUID().uuidString)
        entry["game"] = FetchedReference(recordID: UUID().uuidString)
        entry["questionNumber"] = 1
        entry["isHost"] = true
        entry["rank"] = 1
        return [entry, entry]
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
