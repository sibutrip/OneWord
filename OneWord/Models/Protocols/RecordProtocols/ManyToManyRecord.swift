//
//  ManyToManyRecord.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/25/24.
//

protocol ManyToManyRecord: FetchedRecord { 
    associatedtype RelatedRecord: ManyToManyRecord
    associatedtype Child: TwoParentsChildRecord
}
