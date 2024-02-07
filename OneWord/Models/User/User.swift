//
//  CreatableUser.swift
//  CommandLineToolTest
//
//  Created by Cory Tripathy on 1/31/24.
//

struct User: CreatableRecord {
    enum RecordKeys: String, CaseIterable { case name, systemID }
    static let recordType = "User"
    let id: String
    let name: String
    let systemID: String
}
