//
//  MockDatabase.swift
//  OneWordTests
//
//  Created by Cory Tripathy on 1/25/24.
//

@testable import OneWord
import CloudKit

class MockDatabase: Database {
    func record(for entryID: OneWord.Entry.ID) async throws -> OneWord.Entry {
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
    
    func save(_ entry: OneWord.Entry) async throws -> OneWord.Entry {
        if connectedToDatabase {
            messages.append(.save)
            if savedRecordToDatabase {
                return recordFromDatabase
            }
        }
        throw NSError(domain: "Could not save record to database", code: 0)
    }
    
    func records(matching query: OneWord.ReferenceQuery, desiredKeys: [OneWord.Entry.FieldKey]?, resultsLimit: Int) async throws -> [OneWord.Entry] {
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
    
    func modifyRecords(saving recordsToSave: [OneWord.Entry], deleting recordIDsToDelete: [OneWord.Entry.ID]) async throws -> (saveResults: [OneWord.Entry], deleteResults: [OneWord.Entry.ID]) {
        if connectedToDatabase {
            messages.append(.modify)
            if recordInDatabase {
                return (saveResults: [recordFromDatabase], deleteResults: [])
            }
        }
        throw NSError(domain: "could not modify records in database", code: 0)
    }
    
    
    let recordInDatabase: Bool
    let fetchedCorrectRecordType: Bool
    let connectedToDatabase: Bool
    let savedRecordToDatabase: Bool
    var messages: [Message] = []
    
    private var records: [CKRecord] = []
    
    /// all possible subscripts from database
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
    
    var incorrectRecordFromDatabase: Entry = {
        return Entry(withID: UUID().uuidString, recordType: "IncorrectRecord")
    }()
    
    enum Message {
        case record, save, modify, records
    }
    
    init(recordInDatabase: Bool = true,
         fetchedCorrectRecordType: Bool = true,
         connectedToDatabase: Bool = true,
         savedRecordToDatabase: Bool = true) {
        self.recordInDatabase = recordInDatabase
        self.fetchedCorrectRecordType = fetchedCorrectRecordType
        self.connectedToDatabase = connectedToDatabase
        self.savedRecordToDatabase = savedRecordToDatabase
    }
}
