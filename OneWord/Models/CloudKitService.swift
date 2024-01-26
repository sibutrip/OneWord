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
    
    func add<Child>(_ record: Child, withParent parent: Child.Parent) async throws -> Child where Child : ChildRecord, Child.Parent: Record {
        var record = record
        record.addingParent(parent)
        let childCkRecord = record.ckRecord
        let parentCkRecord = parent.ckRecord
        let receivedRecord = try? await database.record(for: parentCkRecord.recordID)
        do {
            if receivedRecord == nil {
                _ = try await database.save(parentCkRecord)
            } else {
                _ = try await database.modifyRecords(saving: [parentCkRecord], deleting: [])
            }
            _ = try await database.save(childCkRecord)
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
    
    func update<Child>(_ record: Child, addingParent parent: Child.Parent) async throws -> Child where Child : ChildRecord {
        fatalError("not yet implemented")
    }
    init(withContainer container: CloudContainer) {
        self.container = container
    }
}
