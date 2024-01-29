//
//  TwoParentsChildRecord.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/24/24.
//

import CloudKit

protocol TwoParentsChildRecord: ChildRecord {
    associatedtype SecondParent = Record
        
    init?(from record: CKRecord, with secondParent: SecondParent?)
    mutating func addingSecondParent(_ secondParent: SecondParent)
}
