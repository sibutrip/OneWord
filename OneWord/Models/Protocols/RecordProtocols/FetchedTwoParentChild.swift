//
//  FetchedTwoParentChild.swift
//  OneWord
//
//  Created by Cory Tripathy on 3/4/24.
//

protocol FetchedTwoParentsChild: TwoParentsChildRecord, FetchedRecord {
    associatedtype FetchedParent: FetchedRecord
    associatedtype FetchedSecondParent: FetchedRecord
    var parentReference: FetchedReference? { get }
    var secondParentReference: FetchedReference? { get }
}
