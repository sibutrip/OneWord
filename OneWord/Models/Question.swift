//
//  Question.swift
//  CommandLineToolTest
//
//  Created by Cory Tripathy on 1/31/24.
//

struct Question: FetchedRecord {
    init?(from entry: Entry) {
        guard let description = entry["description"] as? String else {
            return nil
        }
        self.id = entry.id
        self.description = description
    }
    
    static let recordType = "Question"
    
    let id: String
    let description: String
}
