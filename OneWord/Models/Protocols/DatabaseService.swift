//
//  DatabaseService.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/22/24.
//

protocol DatabaseService: Actor {
    func add<Child: ChildRecord>(_ record: Child, withParent parent: Child.Parent) async throws
    func add<Child: TwoParentsChildRecord>(_ record: Child, withParent parent: Child.Parent, andSecondParent: Child.SecondParent) async throws
    func fetch<SomeRecord: Record>(withID recordID: String) async throws -> SomeRecord
    func update<Child: ChildRecord>(_ record: Child, addingParent parent: Child.Parent) async throws
    func childRecords<Child: ChildRecord>(of parent: Child.Parent) async throws -> [Child]
    func fetchManyToManyRecords<FromRecord: ManyToManyRecord>(from: FromRecord) async throws -> [FromRecord.RelatedRecord]
}
