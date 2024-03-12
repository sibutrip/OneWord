//
//  DatabaseService.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/22/24.
//

import CloudKit

actor DatabaseService: DatabaseServiceProtocol {
    
    enum DatabaseServiceError: Error {
        case couldNotModifyRecord, couldNotSaveRecord, invalidDataFromDatabase, couldNotGetChildrenFromDatabase, couldNotGetRecordsFromReferences, couldNotGetRecords, couldNotAuthenticate
    }
    
    let container: CloudContainer
    lazy var database = container.public
    
    func save<SomeRecord: CreatableRecord>(_ record: SomeRecord) async throws {
        do {
            _ = try await database.save(record.entry)
        } catch {
            throw DatabaseServiceError.couldNotSaveRecord
        }
    }
    
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
    
#warning("add tests to this")
    func add<SomeRecord>(_ record: SomeRecord, withSecondParent parent: SomeRecord.SecondParent) async throws where SomeRecord : TwoParentsChildRecord, SomeRecord : CreatableRecord, SomeRecord.SecondParent : CreatableRecord {
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
    
    func childRecords<SomeRecord>(of parent: SomeRecord.Parent) async throws -> [SomeRecord] where SomeRecord : ChildRecord, SomeRecord: FetchedRecord, SomeRecord.Parent: CreatableRecord {
        let query = ReferenceQuery(child: SomeRecord.self, parent: parent)
        do {
            let entries = try await database.records(matching: query, desiredKeys: nil, resultsLimit: Int.max)
            let records = entries.compactMap { SomeRecord(from: $0) }
            return records
        } catch {
            throw DatabaseServiceError.couldNotGetChildrenFromDatabase
        }
    }
    
#warning("add to tests")
    func childRecords<SomeRecord>(of parent: SomeRecord.SecondParent) async throws -> [SomeRecord] where SomeRecord: FetchedTwoParentsChild, SomeRecord.Parent: CreatableRecord {
        let query = ReferenceQuery(child: SomeRecord.self, secondParent: parent)
        do {
            let entries = try await database.records(matching: query, desiredKeys: nil, resultsLimit: Int.max)
            let records = entries.compactMap { SomeRecord(from: $0) }
            return records
        } catch {
            throw DatabaseServiceError.couldNotGetChildrenFromDatabase
        }
    }
    
    func fetchManyToManyRecords<Intermediary>(fromParent parent: Intermediary.Parent, withIntermediary intermediary: Intermediary.Type) async throws -> [Intermediary.FetchedSecondParent] where Intermediary: FetchedTwoParentsChild, Intermediary.Parent: Record, Intermediary.FetchedSecondParent: FetchedRecord {
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
        let secondParents = fetchedSecondParentEntries.compactMap { Intermediary.FetchedSecondParent(from: $0) }
        return secondParents
    }
    
    func fetchManyToManyRecords<Intermediary>(fromSecondParent secondParent: Intermediary.SecondParent, withIntermediary intermediary: Intermediary.Type) async throws -> [Intermediary.FetchedParent] where Intermediary: FetchedTwoParentsChild, Intermediary.SecondParent: Record, Intermediary.FetchedParent: FetchedRecord {
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
        let parents = fetchedParentEntries.compactMap { Intermediary.FetchedParent(from: $0) }
        return parents
    }
    
    func newestChildRecord<SomeRecord>(of parent: SomeRecord.Parent) async throws -> SomeRecord where SomeRecord : ChildRecord {
        fatalError("not yet implemented")
    }
    
    func records<SomeRecord>() async throws -> [SomeRecord] where SomeRecord : FetchedRecord {
        guard let fetchedEntries = try? await database.records(forRecordType: SomeRecord.recordType) else {
            throw DatabaseServiceError.couldNotGetRecords
        }
        let records = fetchedEntries.compactMap { SomeRecord(from: $0) }
        return records
    }
    
    func authenticate() async throws -> AuthenticationStatus {
        do {
            return try await database.authenticate()
        } catch {
            throw DatabaseServiceError.couldNotAuthenticate
        }
    }
    
    /// returns nil if record does not exist. if any other error, throws instead
    func record<SomeRecord: FetchedRecord>(forValue value: String, inField field: SomeRecord.RecordKeys) async throws -> SomeRecord? {
        let fieldQuery = FieldQuery(forValue: value, inField: field, forRecordType: SomeRecord.self)
        var entry: Entry?
        do {
            entry = try await database.record(matchingFieldQuery: fieldQuery)
        } catch {
            throw DatabaseServiceError.couldNotGetRecords
        }
        guard let entry else {
            return nil
        }
        guard let record = SomeRecord(from: entry) else {
            fatalError()
        }
        return record
    }

    
    // MARK: Initializer
    
    init(withContainer container: CloudContainer) {
        self.container = container
    }
}
