//
//  MockDatabase.swift
//  OneWordTests
//
//  Created by Cory Tripathy on 1/25/24.
//

@testable import OneWord
import CloudKit

actor MockDatabase: Database {
    
    let fetchedRecordSuccessfully: Bool
    let fetchedCorrectRecordType: Bool
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
        ckRecord["isWinner"] = true
        return ckRecord
    }()
    
    var incorrectRecordFromDatabase: CKRecord = {
        return CKRecord(recordType: "TestRecord")
    }()
    
    func save(_ record: CKRecord) async throws -> CKRecord {
        if records.contains(where: {$0.recordID == record.recordID }) {
            throw NSError(domain: "record already in database", code: 0)
        }
        records.append(record)
        return records.first { $0.recordID == record.recordID }!
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
        var savedRecords = [CKRecord]()
        self.records = records.map { existingRecord in
            if recordsToSave.contains(where: { $0.recordID == existingRecord.recordID }) {
                let recordToSave = recordsToSave.first { $0.recordID == existingRecord.recordID } ?? existingRecord
                savedRecords.append(recordToSave)
                return recordToSave
            } else {
                return existingRecord
            }
        }
        var deletedRecordIDs = [CKRecord.ID]()
        self.records = records.compactMap { existingRecord in
            if recordIDsToDelete.contains(where: { $0 == existingRecord.recordID }) {
                let recordIDToDelete = recordIDsToDelete.first { $0 == existingRecord.recordID } ?? existingRecord.recordID
                deletedRecordIDs.append(recordIDToDelete)
                return nil
            } else {
                return existingRecord
            }
        }
        if savedRecords.isEmpty && deletedRecordIDs.isEmpty {
            throw NSError(domain: "no records modified", code: 0)
        }
        
        let saveResults: [Result<CKRecord, Error>] = savedRecords.map {
            .success($0)
        }
        let saveIDs = savedRecords.map { $0.recordID }
        let zippedSavedRecords = zip(saveIDs, saveResults)
        let saveResultsWithIDs = Dictionary(uniqueKeysWithValues: zippedSavedRecords)
        
        let deleteResults: [Result<Void, Error>] = deletedRecordIDs.map { _ in
                .success({}())
        }
        let zippedDeletedRecords = zip(deletedRecordIDs, deleteResults)
        let deleteResultsWithIDs = Dictionary(uniqueKeysWithValues: zippedDeletedRecords)
        
        return (saveResults: saveResultsWithIDs, deleteResults: deleteResultsWithIDs)
    }
    
    func record(for recordID: CKRecord.ID) async throws -> CKRecord {
        if fetchedRecordSuccessfully {
            messages.append(.record)
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
        case record
    }
    
    init(fetchedRecordSuccessfully: Bool = true,
         fetchedCorrectRecordType: Bool = true) {
        self.fetchedRecordSuccessfully = fetchedRecordSuccessfully
        self.fetchedCorrectRecordType = fetchedCorrectRecordType
    }
}
