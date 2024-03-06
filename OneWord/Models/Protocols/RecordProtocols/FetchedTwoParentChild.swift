//
//  FetchedTwoParentChild.swift
//  OneWord
//
//  Created by Cory Tripathy on 3/4/24.
//

protocol FetchedTwoParentsChild: TwoParentsChildRecord, FetchedRecord {
    var parentReference: FetchedReference? { get }
    var secondParentReference: FetchedReference? { get }
}
