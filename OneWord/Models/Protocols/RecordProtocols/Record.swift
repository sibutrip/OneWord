//
//  Record.swift
//  CommandLineToolTest
//
//  Created by Cory Tripathy on 1/31/24.
//

protocol Record: Identifiable {
//    typealias ID = String
    associatedtype RecordKeys: RawRepresentable, CaseIterable where RecordKeys.RawValue == String
    static var recordType: String { get }
    
    var id: String { get }
}
