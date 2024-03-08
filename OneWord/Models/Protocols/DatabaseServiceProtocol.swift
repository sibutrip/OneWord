//
//  DatabaseService.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/22/24.
//

protocol DatabaseServiceProtocol: Actor {
    func save<SomeRecord: CreatableRecord>(_ record: SomeRecord) async throws
    func add<SomeRecord: ChildRecord>(_ record: SomeRecord, withParent parent: SomeRecord.Parent) async throws where SomeRecord.Parent: CreatableRecord, SomeRecord: CreatableRecord
    func add<SomeRecord: TwoParentsChildRecord>(_ record: SomeRecord, withParent parent: SomeRecord.Parent, withSecondParent secondParent: SomeRecord.SecondParent) async throws where SomeRecord.Parent: CreatableRecord, SomeRecord.SecondParent: CreatableRecord, SomeRecord: CreatableRecord
    func fetch<SomeRecord: FetchedRecord>(withID recordID: String) async throws -> SomeRecord
    func childRecords<SomeRecord: ChildRecord>(of parent: SomeRecord.Parent) async throws -> [SomeRecord] where SomeRecord: FetchedRecord, SomeRecord: ChildRecord, SomeRecord.Parent: FetchedRecord
    func fetchManyToManyRecords<Intermediary: TwoParentsChildRecord>(fromParent parent: Intermediary.Parent, withIntermediary intermediary: Intermediary.Type) async throws -> [Intermediary.FetchedSecondParent] where Intermediary: FetchedTwoParentsChild, Intermediary.Parent: Record, Intermediary.FetchedSecondParent: FetchedRecord
    
    func fetchManyToManyRecords<Intermediary>(fromSecondParent secondParent: Intermediary.SecondParent, withIntermediary intermediary: Intermediary.Type) async throws -> [Intermediary.FetchedParent] where Intermediary: FetchedTwoParentsChild, Intermediary.SecondParent: Record, Intermediary.FetchedParent: FetchedRecord
    
    func newestChildRecord<SomeRecord: ChildRecord>(of parent: SomeRecord.Parent) async throws -> SomeRecord
}
