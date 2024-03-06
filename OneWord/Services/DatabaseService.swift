//
//  DatabaseService.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/22/24.
//

import CloudKit

actor DatabaseService: DatabaseServiceProtocol {
    
    enum DatabaseServiceError: Error {
        case couldNotModifyRecord, couldNotSaveRecord, invalidDataFromDatabase, couldNotGetChildrenFromDatabase, couldNotGetRecordsFromReferences
    }
    
    let container: CloudContainer
    lazy var database = container.public
    
    func add<SomeRecord>(_ record: SomeRecord, withParent parent: SomeRecord.Parent) async throws where SomeRecord : ChildRecord, SomeRecord : CreatableRecord, SomeRecord.Parent : CreatableRecord {
        do {
            _ = try await self.database.modifyRecords(saving: [parent.entry], deleting: [])
        } catch {
            throw DatabaseServiceError.couldNotModifyRecord
        }
        do {
            _ = try await database.save(record.entry)
        } catch {
            throw DatabaseServiceError.couldNotSaveRecord
        }
    }
    
    func add<SomeRecord>(_ record: SomeRecord, withParent parent: SomeRecord.Parent, withSecondParent secondParent: SomeRecord.SecondParent) async throws where SomeRecord : CreatableRecord, SomeRecord : TwoParentsChildRecord, SomeRecord.Parent : CreatableRecord, SomeRecord.SecondParent : CreatableRecord {
        let entry = record.entry
        do {
            _ = try await self.database.modifyRecords(saving: [parent.entry, secondParent.entry], deleting: [])
        } catch {
            throw DatabaseServiceError.couldNotModifyRecord
        }
        do {
            _ = try await database.save(entry)
        } catch {
            throw DatabaseServiceError.couldNotSaveRecord
        }
    }
    
    func fetch<SomeRecord>(withID recordID: String) async throws -> SomeRecord where SomeRecord : FetchedRecord {
        let entry = try await database.record(for: recordID)
        guard let record = SomeRecord(from: entry) else {
            throw DatabaseServiceError.invalidDataFromDatabase
        }
        return record
    }
    
    func childRecords<SomeRecord>(of parent: SomeRecord.Parent) async throws -> [SomeRecord] where SomeRecord : ChildRecord, SomeRecord: FetchedRecord, SomeRecord.Parent: FetchedRecord {
        let query = ReferenceQuery(child: SomeRecord.self, parent: parent)
        do {
            let entries = try await database.records(matching: query, desiredKeys: nil, resultsLimit: Int.max)
            let records = entries.compactMap { SomeRecord(from: $0) }
            return records
        } catch {
            throw DatabaseServiceError.couldNotGetChildrenFromDatabase
        }
    }
    
    func fetchManyToManyRecords<Intermediary>(fromParent parent: Intermediary.Parent, withIntermediary intermediary: Intermediary.Type) async throws -> [FetchedRecord] where Intermediary: FetchedTwoParentsChild, Intermediary.Parent: Record, Intermediary.SecondParent: FetchedRecord {
        let query = ReferenceQuery(child: intermediary.self, parent: parent)
        guard let entries = try? await database.records(matching: query, desiredKeys: nil, resultsLimit: Int.max) else {
            throw DatabaseServiceError.couldNotGetChildrenFromDatabase
        }
        let intermediaryRecordReferences = entries
            .compactMap { Intermediary(from: $0) }
            .compactMap { $0.secondParentReference }
        guard let fetchedSecondParentEntries = try? await database.records(fromReferences: intermediaryRecordReferences) else {
            throw DatabaseServiceError.couldNotGetRecordsFromReferences
        }
        let secondParents = fetchedSecondParentEntries.compactMap { Intermediary.SecondParent(from: $0) }
        return secondParents
    }
    
    func fetchManyToManyRecords<Intermediary>(fromSecondParent secondParent: Intermediary.SecondParent, withIntermediary intermediary: Intermediary.Type) async throws -> [FetchedRecord] where Intermediary: FetchedTwoParentsChild, Intermediary.SecondParent: Record, Intermediary.Parent: FetchedRecord {
        let query = ReferenceQuery(child: intermediary.self, secondParent: secondParent)
        guard let entries = try? await database.records(matching: query, desiredKeys: nil, resultsLimit: Int.max) else {
            throw DatabaseServiceError.couldNotGetChildrenFromDatabase
        }
        let intermediaryRecordReferences = entries
            .compactMap { Intermediary(from: $0) }
            .compactMap { $0.parentReference }
        guard let fetchedParentEntries = try? await database.records(fromReferences: intermediaryRecordReferences) else {
            throw DatabaseServiceError.couldNotGetRecordsFromReferences
        }
        let parents = fetchedParentEntries.compactMap { Intermediary.Parent(from: $0) }
        return parents
    }
    
    func newestChildRecord<SomeRecord>(of parent: SomeRecord.Parent) async throws -> SomeRecord where SomeRecord : ChildRecord {
        fatalError("not yet implemented")
    }
    
    // MARK: Helper Methods
    
    // MARK: Initializer
    
    init(withContainer container: CloudContainer) {
        self.container = container
    }
}


//    func fetchManyToManyRecords<FromRecord>(from: FromRecord) -> [FromRecord.RelatedRecord] where FromRecord : ManyToManyRecord {
//        fatalError("not yet implemented")
//    }

//    func childRecords<Child>(of secondParent: Child.SecondParent) async throws -> [Child] where Child : TwoParentsChildRecord {
//        fatalError("not yet implemented")
//    }

//    func add<Child>(_ record: Child, withParent parent: Child.Parent, andSecondParent secondParent: Child.SecondParent) async throws -> Child where Child : TwoParentsChildRecord, Child.Parent: Record, Child.SecondParent: Record {
//        var record = record
//        record.addingParent(parent)
//        record.addingSecondParent(secondParent)
//        try await modifyOrAdd([record, parent, secondParent])
//        return record
//    }

//    func childRecords<Child>(of parent: Child.Parent) async throws -> [Child] where Child : ChildRecord{
//        fatalError("not yet implemented")
//    }

/// - Parameters:
///   - record: `Child` record to upload to database. Does not need to have its parent property set.
///   - parent: `Parent` record to upload/update in the database. sets the `parent` property of the corresponding `Child` record
/// - Returns: `Child` record with updated `parent` property.
/// - Throws `CloudKitServiceError.couldNotConnectToDatabase` if no internet connection to database.
/// - `Child` and `Parent` can be existing records, or not. With update or add to database accordingly.
//    func add<Child>(_ record: Child, withParent parent: Child.Parent) async throws -> Child where Child : ChildRecord, Child.Parent: Record {
//        var record = record
//        record.addingParent(parent)
//        try await modifyOrAdd([record, parent])
//        return record
//    }

/// - Throws `CloudKitServiceError.recordNotInDatabase` if no record with given `recordID` exists.
/// - Throws `CloudKitServiceError.incorrectlyReadingCloudKitData` if `Record` initializer fails with fetched data. Indicates programmer error.
//    func fetch<SomeRecord>(withID recordID: String) async throws -> SomeRecord where SomeRecord : Record {
//        guard let ckRecord = try? await database.record(for: CKRecord.ID(recordName: recordID)) else {
//            throw CloudKitServiceError.recordNotInDatabase
//        }
//        guard let record = SomeRecord(from: ckRecord) else {
//            throw CloudKitServiceError.incorrectlyReadingCloudKitData
//        }
//        return record
//    }

/// - Throws `CloudKitServiceError.couldNotConnectToDatabase` if unable to fetch records in `database`
/// - Throws `CloudKitServiceError.incorrectlyReadingCloudKitData` if `Record` initializer fails with fetched data. Indicates programmer error.
//    func newestChildRecord<Child>(of parent: Child.Parent) async throws -> Child where Child : ChildRecord {
//        let query = CKQuery(recordType: Child.recordType, predicate: NSPredicate(value: true))
//        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
//        guard let (matchResults, _) = (try? await database.records(matching: query, inZoneWith: .default, desiredKeys: nil, resultsLimit: 1)) else {
//            throw CloudKitServiceError.couldNotConnectToDatabase
//        }
//        let records = matchResults
//            .compactMap { try? $0.1.get() }
//            .compactMap { Child(from: $0, with: parent) }
//
//        guard let record = records.first else {
//            throw CloudKitServiceError.recordNotInDatabase
//        }
//        guard records.count == 1 else {
//            throw CloudKitServiceError.incorrectlyReadingCloudKitData
//        }
//        return record
//    }


