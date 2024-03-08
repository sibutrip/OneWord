//
//  ChildRecord.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/23/24.
//

protocol ChildRecord: Record {
    associatedtype Parent: Record
}
