//
//  Record.swift
//  CommandLineToolTest
//
//  Created by Cory Tripathy on 1/31/24.
//

protocol Record {
    static var recordType: String { get }
    
    var id: String { get }
}
