//
//  DatabaseService.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/22/24.
//

protocol DatabaseService: Actor {
    func add<Child: ChildRecord, SomeRecord: Record>(_ record: Child, withParent parent: SomeRecord) async throws
    func fetch<SomeRecord: Record>(withID recordID: String) async throws -> SomeRecord
    func update<Child: ChildRecord, SomeRecord: Record>(_ record: Child, addingParent parent: SomeRecord) async throws
}
