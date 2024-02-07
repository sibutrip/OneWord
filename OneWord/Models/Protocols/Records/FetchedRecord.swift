//
//  FetchedRecord.swift
//  CommandLineToolTest
//
//  Created by Cory Tripathy on 1/31/24.
//

protocol FetchedRecord: Record {
    init?(from record: any DatabaseEntry)
}
