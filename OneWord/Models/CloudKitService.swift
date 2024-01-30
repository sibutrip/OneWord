//
//  CloudKitService.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/22/24.
//

import CloudKit

actor CloudKitService: DatabaseService {
    
    enum CloudKitServiceError: Error {
        case incorrectlyReadingCloudKitData, recordNotInDatabase, couldNotConnectToDatabase
    }
    
    let container: CloudContainer
    lazy var database = container.public
    func fetchManyToManyRecords<FromRecord>(from: FromRecord) -> [FromRecord.RelatedRecord] where FromRecord : ManyToManyRecord {
        fatalError("not yet implemented")
    }
    
    func childRecords<Child>(of secondParent: Child.SecondParent) async throws -> [Child] where Child : TwoParentsChildRecord {
        fatalError("not yet implemented")
    }
    
    func add<Child>(_ record: Child, withParent parent: Child.Parent, andSecondParent secondParent: Child.SecondParent) async throws -> Child where Child : TwoParentsChildRecord, Child.Parent: Record, Child.SecondParent: Record {
        var record = record
        record.addingParent(parent)
        record.addingSecondParent(secondParent)
        try await modifyOrAdd([record, parent, secondParent])
        return record
    }
    
    func childRecords<Child>(of parent: Child.Parent) async throws -> [Child] where Child : ChildRecord{
        fatalError("not yet implemented")
    }
    
    /// - Parameters:
    ///   - record: `Child` record to upload to database. Does not need to have its parent property set.
    ///   - parent: `Parent` record to upload/update in the database. sets the `parent` property of the corresponding `Child` record
    /// - Returns: `Child` record with updated `parent` property.
    /// - Throws `CloudKitServiceError.couldNotConnectToDatabase` if no internet connection to database.
    /// - `Child` and `Parent` can be existing records, or not. With update or add to database accordingly.
    func add<Child>(_ record: Child, withParent parent: Child.Parent) async throws -> Child where Child : ChildRecord, Child.Parent: Record {
        var record = record
        record.addingParent(parent)
        try await modifyOrAdd([record, parent])
        return record
    }
    
    /// - Throws `CloudKitServiceError.recordNotInDatabase` if no record with given `recordID` exists.
    /// - Throws `CloudKitServiceError.incorrectlyReadingCloudKitData` if `Record` initializer fails with fetched data. Indicates programmer error.
    func fetch<SomeRecord>(withID recordID: String) async throws -> SomeRecord where SomeRecord : Record {
        guard let ckRecord = try? await database.record(for: CKRecord.ID(recordName: recordID)) else {
            throw CloudKitServiceError.recordNotInDatabase
        }
        guard let record = SomeRecord(from: ckRecord) else {
            throw CloudKitServiceError.incorrectlyReadingCloudKitData
        }
        return record
    }
    
    #warning("add to tests")
    func newestChildRecord<Child>(of parent: Child.Parent) async throws -> Child where Child : ChildRecord {
        let query = CKQuery(recordType: Child.recordType, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let (matchResults, _) = try await database.records(matching: query, inZoneWith: .default, desiredKeys: nil, resultsLimit: 1)
        let records = matchResults
            .compactMap { try? $0.1.get() }
            .compactMap { Child(from: $0, with: parent) }
        guard let record = records.first, records.count != 1 else {
            throw CloudKitServiceError.incorrectlyReadingCloudKitData
        }
        return record
    }
    
    // MARK: Initializer
    
    init(withContainer container: CloudContainer) {
        self.container = container
    }
    
    // MARK: Private Methods
    
    /// Determines if record is in database. If record is in database, it calles `database.modifyRecords` to modify an existing record, otherwise it calls `database.save` to save a new record.
    private func modifyOrAdd(_ records: [any Record]) async throws{
        try await withThrowingTaskGroup(of: Void.self) { taskGroup in
            for record in records {
                taskGroup.addTask {
                    do {
                        let ckRecord = record.ckRecord
                        let receivedRecordRequest = try? await self.database.record(for: ckRecord.recordID)
                        if receivedRecordRequest == nil {
                            _ = try await self.database.save(ckRecord)
                        } else {
                            let _ = try await self.database.modifyRecords(saving: [ckRecord], deleting: [])
                        }
                    } catch {
                        throw CloudKitServiceError.couldNotConnectToDatabase
                    }
                }
            }
            try await taskGroup.waitForAll()
        }
    }
}
