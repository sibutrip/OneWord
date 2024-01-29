//
//  DatabaseService.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/22/24.
//

protocol DatabaseService: Actor {
    func add<Child: ChildRecord>(_ record: Child, withParent parent: Child.Parent) async throws -> Child where Child.Parent: Record
    func add<Child: TwoParentsChildRecord>(_ record: Child, withParent parent: Child.Parent, andSecondParent secondParent: Child.SecondParent) async throws -> Child where Child.Parent: Record, Child.SecondParent: Record
    func fetch<SomeRecord: Record>(withID recordID: String) async throws -> SomeRecord
    func childRecords<Child: ChildRecord>(of parent: Child.Parent) async throws -> [Child]
    func fetchManyToManyRecords<FromRecord: ManyToManyRecord>(from: FromRecord) async throws -> [FromRecord.RelatedRecord]
}
