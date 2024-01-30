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
        let predicate = query.predicate
        let fieldToMatch = predicate.predicateFormat.components(separatedBy: " == ").first ?? ""
        let results: [(CKRecord.ID, Result<CKRecord, any Error>)] = records.compactMap { record in
            if !fieldToMatch.isEmpty && fieldToMatch != "TRUEPREDICATE" {
                let resultAsReference = record[fieldToMatch] as? CKRecord.Reference
                let resultAsString = record[fieldToMatch] as? String
                if resultAsString == nil && resultAsReference == nil {
                    return nil
                }
                let result: Result<CKRecord, any Error> = .success(record)
                return (record.recordID, result)
            }
            let result: Result<CKRecord, any Error> = .success(record)
            return (record.recordID, result)
        }
        return (matchResults: results, queryCursor: nil)
    }
    
    func modifyRecords(saving recordsToSave: [CKRecord], deleting recordIDsToDelete: [CKRecord.ID]) async throws -> (saveResults: [CKRecord.ID : Result<CKRecord, Error>], deleteResults: [CKRecord.ID : Result<Void, Error>]) {
        messages.append(.modify)
        if connectedToDatabase && connectedToDatabase {
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
        case record, save, modify
    }
    
    init(recordInDatabase: Bool = true,
         fetchedCorrectRecordType: Bool = true,
         connectedToDatabase: Bool = true) {
        self.recordInDatabase = recordInDatabase
        self.fetchedCorrectRecordType = fetchedCorrectRecordType
        self.connectedToDatabase = connectedToDatabase
    }
}
