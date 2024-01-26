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
    
    func add<Child>(_ record: Child, withParent parent: Child.Parent, andSecondParent: Child.SecondParent) async throws -> Child where Child : TwoParentsChildRecord{
        fatalError("not yet implemented")
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
        let childCkRecord = record.ckRecord
        let parentCkRecord = parent.ckRecord
        async let receivedParentRecordRequest = try? await database.record(for: parentCkRecord.recordID)
        async let receivedChildRecordRequest = try? await database.record(for: childCkRecord.recordID)
        let (receivedParentRecord, receivedChildRecord) = (await receivedParentRecordRequest, await receivedChildRecordRequest)
        do {
            if receivedParentRecord == nil {
                _ = try await database.save(parentCkRecord)
            } else {
                let _ = try await database.modifyRecords(saving: [parentCkRecord], deleting: [])
            }
            if receivedChildRecord == nil {
                _ = try await database.save(childCkRecord)
            } else {
                let _ = try await database.modifyRecords(saving: [childCkRecord], deleting: [])
            }
        } catch {
            throw CloudKitServiceError.couldNotConnectToDatabase
        }
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
    
    init(withContainer container: CloudContainer) {
        self.container = container
    }
}
