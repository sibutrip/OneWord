//
//  Question.swift
//  CommandLineToolTest
//
//  Created by Cory Tripathy on 1/31/24.
//

struct Question: FetchedRecord {
    init?(from record: any DatabaseEntry) {
        guard let description = record["description"] as? String else {
            return nil
        }
        self.id = record.recordName
        self.description = description
    }
    
    static let recordType = "Question"
    
    let id: String
    let description: String
}
