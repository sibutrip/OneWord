//
//  CKDatabase+Database.swift
//  OneWord
//
//  Created by Cory Tripathy on 3/8/24.
//

import CloudKit

extension CKDatabase: Database {
    
    func record(matchingFieldQuery fieldQuery: FieldQuery) async throws -> Entry? {
        let predicate = NSPredicate(format: "\(fieldQuery.field) == %@", fieldQuery.value)
        let query = CKQuery(recordType: fieldQuery.recordType, predicate: predicate)
        let (resultsById,_) = try await self.records(matching: query)
        let results = resultsById.map { $0.1 }
        let ckRecords = results.compactMap { try? $0.get() }
        let entries: [Entry] = ckRecords.map { ckRecord in
            var entry = Entry(withID: ckRecord.recordID.recordName, recordType: ckRecord.recordType)
            for key in ckRecord.allKeys() {
                if let ckRecordValue = ckRecord[key] {
                    entry[key] = ckRecordValue
                }
            }
            return entry
        }
        return entries.first
    }
    
    func authenticate() async throws -> AuthenticationStatus {
        let accountStatus = try await CKContainer.default().accountStatus()
        switch accountStatus {
        case .couldNotDetermine:
            return.couldNotDetermineAccountStatus
        case .available:
            do {
                let ckID = try await CKContainer.default().userRecordID()
                return.available(ckID.recordName)
            } catch {
                return .couldNotDetermineAccountStatus
            }
        case .restricted:
            return .accountRestricted
        case .noAccount:
            return .noAccount
        case .temporarilyUnavailable:
            return .accountTemporarilyUnavailable
        @unknown default:
            fatalError()
        }
    }
    
    func records(forRecordType type: String) async throws -> [Entry] {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: type, predicate: predicate)
        let (resultsById,_) = try await self.records(matching: query)
        let results = resultsById.map { $0.1 }
        let ckRecords = results.compactMap { try? $0.get() }
        let entries: [Entry] = ckRecords.map { ckRecord in
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
        // TODO: mapping logic. separate this. ckrecord to concrete as well.
        let ckRecord = CKRecord(recordType: entry.recordType, recordID: .init(recordName: entry.id))
        for key in entry.allKeys() {
            if let entryValue = entry[key] as? FetchedReference {
                let reference = CKRecord.Reference(recordID: .init(recordName: entryValue.recordName), action: .none)
                ckRecord[key] = reference
            } else if let entryValue = entry[key] as? __CKRecordObjCValue {
                ckRecord[key] = entryValue
            } else if let _ = entry[key] {
                // dont throw if entry has a value of nil (word.rank can be nil)
                continue
            } else {
                fatalError("invalid record value. check that this record value is convertable to a ckRecord value.")
            }
        }
        try await self.save(ckRecord)
    }
    
    func records(withIDs ids: [Entry.ID]) async throws -> [Entry] {
        let ckIDs = ids.map { CKRecord.ID(recordName: $0) }
        let results = try await self.records(for: ckIDs)
        let ckRecords = results.values.compactMap { try? $0.get() }
        let entries: [Entry] = ckRecords.map { ckRecord in
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
    
    func records(matching referenceQuery: ReferenceQuery, desiredKeys: [Entry.FieldKey]?, resultsLimit: Int) async throws -> [Entry] {
        let desiredKeys = desiredKeys as [CKRecord.FieldKey]?
        // reference made from parent record (searching child records for field with parent reference)
#warning("do i need to refecth the parent ck record?")
        guard let parentCkRecord = try? await self.record(for: CKRecord.ID(recordName: referenceQuery.parentRecord.id)) else { return [] }
        let reference = CKRecord.Reference(record: CKRecord(recordType: referenceQuery.parentRecordType, recordID: parentCkRecord.recordID), action: .none)
        let predicate = NSPredicate(format: "\(referenceQuery.parentRecordType) == %@", reference)
#warning("does this throw because there are no matching records?")
        let query = CKQuery(recordType: referenceQuery.childRecordType, predicate: predicate)
        if referenceQuery.childRecordType == "Round" {
            query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        }
        guard let (matchResults,_) = try? await records(matching: query, inZoneWith: nil, desiredKeys: desiredKeys) else { print("no m2m records found!!"); return [] }
        let entries: [Entry] = matchResults.compactMap { (ckID, ckResult) in
            guard let ckRecord = try? ckResult.get() else { return nil }
            var entry = Entry(withID: ckRecord.recordID.recordName, recordType: ckRecord.recordType)
            for key in ckRecord.allKeys() {
                if let ckRecordValue = ckRecord[key] {
                    if let ckReference = ckRecordValue as? CKRecord.Reference {
                        let fetchedReference = FetchedReference(recordID: ckReference.recordID.recordName, recordType: key)
                        entry[key] = fetchedReference
                    } else {
                        entry[key] = ckRecordValue
                    }
                }
            }
            return entry
        }
        return entries
    }
    
    func modifyRecords(saving recordsToSave: [Entry], deleting recordIDsToDelete: [Entry.ID]) async throws -> (saveResults: [Entry], deleteResults: [Entry.ID]) {
        var ckRecordsToSave = [CKRecord]()
        for entry in recordsToSave {
            guard let ckRecord: CKRecord = try? await self.record(for: .init(recordName: entry.id)) else { fatalError("record not in db") }
            for key in entry.allKeys() {
                if let entryValue = entry[key] as? __CKRecordObjCValue {
                    ckRecord[key] = entryValue
                } else if let entryValue = entry[key] as? FetchedReference {
                    let reference = CKRecord.Reference(recordID: CKRecord.ID(recordName: entryValue.recordName), action: .none)
                    ckRecord[key] = reference
                }  else if let _ = entry[key] {
                    ckRecord[key] = nil
                } else {
                    fatalError("not able to turn entry into ckrecord")
                }
            }
            ckRecordsToSave.append(ckRecord)
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
