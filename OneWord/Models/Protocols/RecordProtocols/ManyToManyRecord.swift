//
//  ManyToManyRecord.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/25/24.
//

protocol ManyToManyRecord: Record {
    associatedtype RelatedRecord: ManyToManyRecord
    associatedtype Child: TwoParentsChildRecord
    var child: Child { get set }
}
