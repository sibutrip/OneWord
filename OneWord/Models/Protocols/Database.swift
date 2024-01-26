//
//  Database.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/25/24.
//

import CloudKit

protocol Database {
    
    func record(for recordID: CKRecord.ID) async throws -> CKRecord
    
    func save(_ record: CKRecord) async throws -> CKRecord
    
    func records(
        matching query: CKQuery,
        inZoneWith zoneID: CKRecordZone.ID?,
        desiredKeys: [CKRecord.FieldKey]?,
        resultsLimit: Int
    ) async throws -> (matchResults: [(CKRecord.ID, Result<CKRecord, Error>)], queryCursor: CKQueryOperation.Cursor?)
    
    func modifyRecords(
        saving recordsToSave: [CKRecord],
        deleting recordIDsToDelete: [CKRecord.ID]) async throws -> (saveResults: [CKRecord.ID : Result<CKRecord, Error>], deleteResults: [CKRecord.ID : Result<Void, Error>])
}
