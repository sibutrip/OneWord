//
//  MockDatabase.swift
//  OneWordTests
//
//  Created by Cory Tripathy on 1/25/24.
//

@testable import OneWord
import Foundation

class MockDatabase: Database {
    
    func record(matchingFieldQuery: FieldQuery) async throws -> Entry? {
        if connectedToDatabase {
            messages.append(.record)
            if recordInDatabase {
                return recordFromDatabase
            } else {
                return nil
            }
        }
        throw NSError(domain: "Could not connect to database", code: 0)
    }
    
    func save(_ entry: Entry) async throws {
        if connectedToDatabase {
            messages.append(.save)
            if savedRecordToDatabase {
                return
            }
        }
        throw NSError(domain: "Could not save record to database", code: 0)
    }
    
    func records(fromReferences fetchedReference: [FetchedReference]) async throws -> [Entry] {
        messages.append(.recordsFromReferences)
        return [recordFromDatabase]
    }
    
    func record(for entryID: Entry.ID) async throws -> Entry {
        if recordInDatabase && connectedToDatabase {
            messages.append(.record)
            if fetchedCorrectRecordType {
                return recordFromDatabase
            } else {
                return incorrectRecordFromDatabase
            }
        }
        throw NSError(domain: "Record not in database", code: 0)
    }
    
    func records(matching query: ReferenceQuery, desiredKeys: [Entry.FieldKey]?, resultsLimit: Int) async throws -> [Entry] {
        if connectedToDatabase {
            messages.append(.records)
            if !fetchedCorrectRecordType {
                return [incorrectRecordFromDatabase]
            }
            if recordInDatabase {
                return [recordFromDatabase]
            } else {
                return []
            }
        }
        throw NSError(domain: "Records not in database", code: 0)
    }
    
    func modifyRecords(saving recordsToSave: [Entry], deleting recordIDsToDelete: [Entry.ID]) async throws -> (saveResults: [Entry], deleteResults: [Entry.ID]) {
        if connectedToDatabase {
            messages.append(.modify)
            if recordInDatabase {
                return (saveResults: [recordFromDatabase], deleteResults: [])
            }
        }
        throw NSError(domain: "could not modify records in database", code: 0)
    }
    
    func records(forRecordType type: String) async throws -> [Entry] {
        if connectedToDatabase {
            messages.append(.records)
            return [recordFromDatabase]
        }
        throw NSError(domain: "could not fetch records in database", code: 0)
    }
    
    func authenticate() async throws -> AuthenticationStatus {
        if connectedToDatabase {
            messages.append(.authenticate)
            return authenticationStatus
        }
        throw NSError(domain: "could not authenticate with database", code: 0)
    }
    
    let authenticationStatus: AuthenticationStatus
    let recordInDatabase: Bool
    let fetchedCorrectRecordType: Bool
    let connectedToDatabase: Bool
    let savedRecordToDatabase: Bool
    var messages: [Message] = []
        
    /// all possible subscripts from database
    var recordFromDatabase: Entry = {
        var entry = Entry(withID: UUID().uuidString, recordType: "MockRecord")
        entry["systemUserID"] = "test id"
        entry["name"] = "test name"
        entry["inviteCode"] = "test invite code"
        entry["questionInfo"] = "my amazing question"
        entry["roundNumber"] = 1
        entry["user"] = FetchedReference(recordID: UUID().uuidString, recordType: "user")
        entry["round"] = FetchedReference(recordID: UUID().uuidString, recordType: "round")
        entry["game"] = FetchedReference(recordID: UUID().uuidString, recordType: "game")
        entry["questionNumber"] = 1
        entry["isHost"] = true
        entry["rank"] = 1
        return entry
    }()
    
    var incorrectRecordFromDatabase: Entry = {
        return Entry(withID: UUID().uuidString, recordType: "IncorrectRecord")
    }()
    
    enum Message {
        case record, save, modify, records, recordsFromReferences, authenticate
    }
    
    init(recordInDatabase: Bool = true,
         fetchedCorrectRecordType: Bool = true,
         connectedToDatabase: Bool = true,
         savedRecordToDatabase: Bool = true,
         authenticationStatus: AuthenticationStatus) {
        self.recordInDatabase = recordInDatabase
        self.fetchedCorrectRecordType = fetchedCorrectRecordType
        self.connectedToDatabase = connectedToDatabase
        self.savedRecordToDatabase = savedRecordToDatabase
        self.authenticationStatus = authenticationStatus
    }
}
