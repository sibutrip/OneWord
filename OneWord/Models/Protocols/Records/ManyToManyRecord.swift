//
//  ManyToManyRecord.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/25/24.
//

import Foundation

protocol ManyToManyRecord: FetchedRecord { 
    associatedtype RelatedRecord: ManyToManyRecord
    associatedtype Child: TwoParentsChildRecord
}
