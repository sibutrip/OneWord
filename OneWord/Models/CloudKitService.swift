//
//  CloudKitService.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/22/24.
//

import Foundation

actor CloudKitService: DatabaseService {
    func fetchManyToManyRecords<FromRecord>(from: FromRecord) -> [FromRecord.RelatedRecord] where FromRecord : ManyToManyRecord {
        fatalError("not yet implemented")
    }
    
    func childRecords<Child>(of secondParent: Child.SecondParent) async throws -> [Child] where Child : TwoParentsChildRecord {
        fatalError("not yet implemented")
    }
        
    func add<Child>(_ record: Child, withParent parent: Child.Parent, andSecondParent: Child.SecondParent) async throws where Child : TwoParentsChildRecord{
        fatalError("not yet implemented")
    }
    
    func childRecords<Child>(of parent: Child.Parent) async throws -> [Child] where Child : ChildRecord{
        fatalError("not yet implemented")
    }
    
    func add<Child>(_ record: Child, withParent parent: Child.Parent) async throws where Child : ChildRecord {
        fatalError("not yet implemented")
    }
    
    func fetch<SomeRecord>(withID recordID: String) async throws -> SomeRecord where SomeRecord : Record {
        fatalError("not yet implemented")
    }
    
    func update<Child>(_ record: Child, addingParent parent: Child.Parent) async throws where Child : ChildRecord {
        fatalError("not yet implemented")
    }
}
