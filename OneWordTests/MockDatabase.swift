//
//  MockDatabase.swift
//  OneWordTests
//
//  Created by Cory Tripathy on 1/25/24.
//

@testable import OneWord
import CloudKit

class MockDatabase: Database {
    
    let recordInDatabase: Bool
    let fetchedCorrectRecordType: Bool
    let connectedToDatabase: Bool
    var messages: [Message] = []
    
    private var records: [CKRecord] = []
    
    /// all possible subscripts from database
    var recordFromDatabase: CKRecord = {
        let ckRecord = CKRecord(recordType: "TestRecord")
        ckRecord["systemUserID"] = "test id"
        ckRecord["name"] = "test name"
        ckRecord["inviteCode"] = "test invite code"
        ckRecord["description"] = "description"
        ckRecord["roundNumber"] = 1
        ckRecord["user"] = CKRecord.Reference(recordID: .init(recordName: "Test"), action: .none)
        ckRecord["round"] = CKRecord.Reference(recordID: .init(recordName: "Test"), action: .none)
        ckRecord["game"] = CKRecord.Reference(recordID: .init(recordName: "Test"), action: .none)
        ckRecord["questionNumber"] = 1
        ckRecord["isHost"] = true
        ckRecord["rank"] = 1
        return ckRecord
    }()
    
    var incorrectRecordFromDatabase: CKRecord = {
        return CKRecord(recordType: "TestRecord")
    }()
    
    func save(_ record: CKRecord) async throws -> CKRecord {
        messages.append(.save)
        if connectedToDatabase {
            return record
        } else {
            throw NSError(domain: "MockDatabase Error", code: 0)
        }
    }
    
    func records(matching query: CKQuery, inZoneWith zoneID: CKRecordZone.ID? = nil, desiredKeys: [CKRecord.FieldKey]? = nil, resultsLimit: Int = CKQueryOperation.maximumResults) async throws -> (matchResults: [(CKRecord.ID, Result<CKRecord, Error>)], queryCursor: CKQueryOperation.Cursor?) {
        if connectedToDatabase {
            messages.append(.records)
            let recordID = recordFromDatabase.recordID
            let saveResult: Result<CKRecord, Error> = Result.success(recordFromDatabase)
            if !fetchedCorrectRecordType {
                return (matchResults: [(recordID, saveResult), (recordID, saveResult)], queryCursor: nil)
            }
            if recordInDatabase {
                return (matchResults: [(recordID, saveResult)], queryCursor: nil)
            } else {
                return (matchResults: [], queryCursor: nil)
            }
        } else {
            throw NSError(domain: "MockDatabase Error", code: 1)
        }
    }
    
    func modifyRecords(saving recordsToSave: [CKRecord], deleting recordIDsToDelete: [CKRecord.ID]) async throws -> (saveResults: [CKRecord.ID : Result<CKRecord, Error>], deleteResults: [CKRecord.ID : Result<Void, Error>]) {
        messages.append(.modify)
        if connectedToDatabase {
            let recordID = recordFromDatabase.recordID
            let saveResult: Result<CKRecord, Error> = Result.success(recordFromDatabase)
            let deleteResult: Result<Void,Error> = Result.success(())
            return (saveResults: [recordID: saveResult], deleteResults: [recordID: deleteResult])
        } else {
            throw NSError(domain: "MockDatabase Error", code: 1)
        }
    }
    
    func record(for recordID: CKRecord.ID) async throws -> CKRecord {
        messages.append(.record)
        if recordInDatabase && connectedToDatabase {
            if fetchedCorrectRecordType {
                return recordFromDatabase
            } else {
                return incorrectRecordFromDatabase
            }
        } else {
            throw NSError(domain: "MockDatabase Error", code: 1)
        }
    }
    
    enum Message {
        case record, save, modify, records
    }
    
    init(recordInDatabase: Bool = true,
         fetchedCorrectRecordType: Bool = true,
         connectedToDatabase: Bool = true) {
        self.recordInDatabase = recordInDatabase
        self.fetchedCorrectRecordType = fetchedCorrectRecordType
        self.connectedToDatabase = connectedToDatabase
    }
}
