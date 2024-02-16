//
//  DatabaseService.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/22/24.
//

protocol DatabaseServiceProtocol: Actor {
    func add<SomeRecord: ChildRecord>(_ record: SomeRecord, withParent parent: SomeRecord.Parent) async throws where SomeRecord.Parent: CreatableRecord, SomeRecord: CreatableRecord
    func add<SomeRecord: TwoParentsChildRecord>(_ record: SomeRecord, withParent parent: SomeRecord.Parent, withSecondParent secondParent: SomeRecord.SecondParent) async throws where SomeRecord.Parent: CreatableRecord, SomeRecord.SecondParent: CreatableRecord, SomeRecord: CreatableRecord
    func fetch<SomeRecord: FetchedRecord>(withID recordID: String) async throws -> SomeRecord
    func childRecords<SomeRecord: ChildRecord>(of parent: SomeRecord.Parent) async throws -> [SomeRecord] where SomeRecord: FetchedRecord, SomeRecord: ChildRecord, SomeRecord.Parent: FetchedRecord
    func fetchManyToManyRecords<FromRecord: ManyToManyRecord>(from: FromRecord) async throws -> [FromRecord.RelatedRecord]
    func newestChildRecord<SomeRecord: ChildRecord>(of parent: SomeRecord.Parent) async throws -> SomeRecord
}
