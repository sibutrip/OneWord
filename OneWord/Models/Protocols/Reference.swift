//
//  Reference.swift
//  CommandLineToolTest
//
//  Created by Cory Tripathy on 1/31/24.
//

protocol EntryReference {
    var recordName: String { get }
    init(recordID: String)
}
