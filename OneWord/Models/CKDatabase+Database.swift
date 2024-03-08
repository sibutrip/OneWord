//
//  CKDatabase+Database.swift
//  OneWord
//
//  Created by Cory Tripathy on 3/8/24.
//

import CloudKit

extension CKDatabase: Database {
    func records(fromReferences fetchedReference: [FetchedReference]) -> [Entry] {
        fatalError("not yet implemented")
    }
    
    func record(for entryID: Entry.ID) async throws -> Entry {
        let ckRecordID = CKRecord.ID(recordName: entryID)
        let ckRecord: CKRecord = try await self.record(for: ckRecordID)
        var entry = Entry(withID: ckRecord.recordID.recordName, recordType: ckRecord.recordType)
        for key in ckRecord.allKeys() {
            entry[key] = ckRecord[key]
        }
        return entry
    }
    
    func save(_ entry: Entry) async throws {
        // mapping logic. separate this. ckrecord to concrete as well.
        let ckRecord = CKRecord(recordType: entry.recordType)
        for key in entry.allKeys() {
            if let entryValue = entry[key] as? FetchedReference {
                let reference = CKRecord.Reference(recordID: .init(recordName: entryValue.recordName), action: .none)
                ckRecord[key] = reference
            } else if let entryValue = entry[key] as? FetchedReference {
                ckRecord[key] = CKRecord.Reference(recordID: CKRecord.ID(recordName: entryValue.recordName), action: .none)
            } else {
                fatalError("not able to turn entry into ckrecord")
            }
        }
        try await self.save(ckRecord)
    }
    
    func records(matching referenceQuery: ReferenceQuery, desiredKeys: [Entry.FieldKey]?, resultsLimit: Int) async throws -> [Entry] {
        let desiredKeys = desiredKeys as [CKRecord.FieldKey]?
        // reference made from parent record (searching child records for field with parent reference)
        let reference = CKRecord.Reference(record: CKRecord(recordType: referenceQuery.parentRecordType, recordID: CKRecord.ID(recordName: referenceQuery.parentRecord.id)), action: .none)
        let predicate = NSPredicate(format: "\(referenceQuery.parentRecordType) == %@", reference)
        let (matchResults,_) = try await records(matching: CKQuery(recordType: referenceQuery.childRecordType, predicate: predicate), inZoneWith: nil, desiredKeys: desiredKeys, resultsLimit: .max)
        let entries: [Entry] = matchResults.compactMap { (ckID, ckResult) in
            guard let ckRecord = try? ckResult.get() else { return nil }
            var entry = Entry(withID: ckRecord.recordID.recordName, recordType: ckRecord.recordType)
            for key in ckRecord.allKeys() {
                if let ckRecordValue = ckRecord[key] {
                    entry[key] = ckRecordValue
                }
            }
            return entry
        }
        return entries
    }
    
    func modifyRecords(saving recordsToSave: [Entry], deleting recordIDsToDelete: [Entry.ID]) async throws -> (saveResults: [Entry], deleteResults: [Entry.ID]) {
        let ckRecordsToSave = recordsToSave.map { entry in
            let ckRecord = CKRecord(recordType: entry.recordType, recordID: CKRecord.ID(recordName: entry.id))
            for key in entry.allKeys() {
                if let entryValue = entry[key] as? __CKRecordObjCValue {
                    ckRecord[key] = entryValue
                } else if let entryValue = entry[key] as? FetchedReference {
                    let reference = CKRecord.Reference(recordID: CKRecord.ID(recordName: entryValue.recordName), action: .none)
                    ckRecord[key] = reference
                } else {
                    fatalError("not able to turn entry into ckrecord")
                }
            }
            return ckRecord
        }
        let ckIDsToDelete = recordIDsToDelete.map {
            return CKRecord.ID(recordName: $0)
        }
        let (saveResults, deleteResults) = try await self.modifyRecords(saving: ckRecordsToSave, deleting: ckIDsToDelete)
        let entriesSaved: [Entry] = saveResults.compactMap { result in
            guard let ckRecord = try? result.value.get() else { return nil }
            return Entry(withID: ckRecord.recordID.recordName, recordType: ckRecord.recordType)
        }
        let entryIDsDeleted: [Entry.ID] = deleteResults.map {
            $0.key.recordName
        }
        return (saveResults: entriesSaved, deleteResults: entryIDsDeleted)
    }
    
    
}
