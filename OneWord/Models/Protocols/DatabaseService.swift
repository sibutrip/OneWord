//
//  DatabaseService.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/22/24.
//

protocol DatabaseService: Actor {
    func add<SomeRecord: ChildRecord>(_ record: SomeRecord, withParent parent: SomeRecord.Parent) async throws where SomeRecord.Parent: Record, SomeRecord: CreatableRecord
    func add<SomeRecord: TwoParentsChildRecord>(_ record: SomeRecord, withParent parent: SomeRecord.Parent, withSecondParent secondParent: SomeRecord.SecondParent) async throws where SomeRecord.Parent: Record, SomeRecord.SecondParent: Record, SomeRecord: CreatableRecord
    func fetch<SomeRecord: FetchedRecord>(withID recordID: String) async throws -> SomeRecord
    func childRecords<SomeRecord: ChildRecord>(of parent: SomeRecord.Parent) async throws -> [SomeRecord]
    func fetchManyToManyRecords<FromRecord: ManyToManyRecord>(from: FromRecord) async throws -> [FromRecord.RelatedRecord]
    func newestChildRecord<SomeRecord: ChildRecord>(of parent: SomeRecord.Parent) async throws -> SomeRecord
}
