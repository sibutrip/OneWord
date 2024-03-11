//
//  MockDatabaseService.swift
//  OneWordTests
//
//  Created by Cory Tripathy on 1/22/24.
//

import XCTest
@testable import OneWord

actor DatabaseServiceSpy: DatabaseServiceProtocol {
    
    func save<SomeRecord>(_ record: SomeRecord) async throws where SomeRecord : OneWord.CreatableRecord {
        if didAddSuccessfully {
            receivedMessages.append(.save)
        } else {
            throw NSError(domain: "MockDatabaseServiceError", code: 0)
        }
    }
    
    func add<SomeRecord>(_ record: SomeRecord, withParent parent: SomeRecord.Parent) async throws where SomeRecord : OneWord.ChildRecord, SomeRecord : OneWord.CreatableRecord, SomeRecord.Parent : OneWord.CreatableRecord {
        if didAddSuccessfully {
            receivedMessages.append(.add)
        } else {
            throw NSError(domain: "MockDatabaseServiceError", code: 1)
        }
    }
    
    func add<SomeRecord>(_ record: SomeRecord, withParent parent: SomeRecord.Parent, withSecondParent secondParent: SomeRecord.SecondParent) async throws where SomeRecord : OneWord.CreatableRecord, SomeRecord : OneWord.TwoParentsChildRecord, SomeRecord.Parent : OneWord.CreatableRecord, SomeRecord.SecondParent : OneWord.CreatableRecord {
        if didAddSuccessfully {
            receivedMessages.append(.add)
        } else {
            throw NSError(domain: "MockDatabaseServiceError", code: 2)
        }
    }
    
    func newestChildRecord<Child>(of parent: Child.Parent) async throws -> Child where Child : OneWord.ChildRecord {
        if didFetchChildRecordsSuccessfully {
            receivedMessages.append(.newestChildRecord)
            fatalError()
            //            return Child(from: recordFromDatabase)!
        } else {
            throw NSError(domain: "MockDatabaseServiceError", code: 3)
        }
    }
    
    func fetch<SomeRecord>(withID recordID: String) async throws -> SomeRecord where SomeRecord : OneWord.FetchedRecord {
        if didFetchSuccessfully {
            receivedMessages.append(.fetch)
            return SomeRecord(from: recordFromDatabase)!
        } else {
            throw NSError(domain: "MockDatabaseServiceError", code: 4)
        }
    }
    
    func childRecords<SomeRecord>(of parent: SomeRecord.Parent) async throws -> [SomeRecord] where SomeRecord : OneWord.ChildRecord, SomeRecord : OneWord.FetchedRecord, SomeRecord.Parent : OneWord.CreatableRecord {
        if didFetchChildRecordsSuccessfully {
            receivedMessages.append(.fetchChildRecords)
            return [SomeRecord(from: recordFromDatabase)!]
        } else {
            throw NSError(domain: "MockDatabaseServiceError", code: 5)
        }
    }
    
    func childRecords<SomeRecord>(of parent: SomeRecord.SecondParent) async throws -> [SomeRecord] where SomeRecord : OneWord.FetchedTwoParentsChild, SomeRecord.Parent : OneWord.CreatableRecord {
        if didFetchChildRecordsSuccessfully {
            receivedMessages.append(.fetchChildRecords)
            return [SomeRecord(from: recordFromDatabase)!]
        } else {
            throw NSError(domain: "MockDatabaseServiceError", code: 5)
        }    }
    
    func fetchManyToManyRecords<Intermediary>(fromSecondParent secondParent: Intermediary.SecondParent, withIntermediary intermediary: Intermediary.Type) async throws -> [Intermediary.FetchedParent] where Intermediary : OneWord.FetchedTwoParentsChild {
        if didFetchChildRecordsSuccessfully {
            receivedMessages.append(.fetchManyToMany)
            return [Intermediary.FetchedParent(from: recordFromDatabase)!]
        } else {
            throw NSError(domain: "MockDatabaseServiceError", code: 6)
        }
    }
    
    func fetchManyToManyRecords<Intermediary>(fromParent parent: Intermediary.Parent, withIntermediary intermediary: Intermediary.Type) async throws -> [Intermediary.FetchedSecondParent] where Intermediary : FetchedTwoParentsChild {
        if didFetchChildRecordsSuccessfully {
            receivedMessages.append(.fetchManyToMany)
            return [Intermediary.FetchedSecondParent(from: recordFromDatabase)!]
        } else {
            throw NSError(domain: "MockDatabaseServiceError", code: 6)
        }
    }
    
    func records<SomeRecord>(forType recordType: SomeRecord.Type) async throws -> [SomeRecord] where SomeRecord : OneWord.FetchedRecord {
        if didFetchSuccessfully {
            receivedMessages.append(.recordsForType)
            return [SomeRecord(from: recordFromDatabase)!]
        }
        throw NSError(domain: "MockDatabaseServiceError", code: 7)
    }
    
    enum Message {
        case add, fetch, update, fetchChildRecords, fetchManyToMany, newestChildRecord, save, recordsForType
    }
    
    var recordFromDatabase: Entry = {
        var entry = Entry(withID: UUID().uuidString, recordType: "MockRecord")
        entry["systemID"] = "fetcher user id"
        entry["wordDescription"] = "my amazing word"
        entry["name"] = "fetched user"
        entry["inviteCode"] = "fetched invite code"
        entry["questionInfo"] = "my amazing question"
        entry["roundNumber"] = 1
        entry["user"] = FetchedReference(recordID: UUID().uuidString, recordType: "user")
        entry["host"] = FetchedReference(recordID: UUID().uuidString, recordType: "user")
        entry["round"] = FetchedReference(recordID: UUID().uuidString, recordType: "round")
        entry["game"] = FetchedReference(recordID: UUID().uuidString, recordType: "game")
        entry["question"] = FetchedReference(recordID: UUID().uuidString, recordType: "question")
        entry["rank"] = 1
        return entry
    }()
    
    var didAddSuccessfully: Bool
    var didFetchSuccessfully: Bool
    var didUpdateSuccessfully: Bool
    var didFetchChildRecordsSuccessfully: Bool
    
    var receivedMessages: [Message] = []
    
    func setDidFetchChildRecordsSuccessfully(to newValue: Bool) {
        self.didFetchChildRecordsSuccessfully = newValue
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
