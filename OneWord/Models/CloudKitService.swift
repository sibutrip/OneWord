//
//  CloudKitService.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/22/24.
//

import Foundation

actor CloudKitService: DatabaseServiceProtocol {
    func add<Child, SomeRecord>(_ record: Child, withParent parent: SomeRecord) async throws where Child : ChildRecord, SomeRecord : Record {
        fatalError("not yet implemented")
    }
    
    func fetch<SomeRecord>(withID recordID: String) async throws -> SomeRecord where SomeRecord : Record {
        fatalError("not yet implemented")
    }
    
    func update<Child, SomeRecord>(_ record: Child, addingParent parent: SomeRecord) async throws where Child : ChildRecord, SomeRecord : Record {
        fatalError("not yet implemented")
    }
}
