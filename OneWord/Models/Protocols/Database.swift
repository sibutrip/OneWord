//
//  Database.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/25/24.
//

protocol Database {
    
    func record(for entryID: Entry.ID) async throws -> Entry
    
    func save(_ entry: Entry) async throws
    
    func records(
        matching referenceQuery: ReferenceQuery,
        desiredKeys: [Entry.FieldKey]?,
        resultsLimit: Int
    ) async throws -> [Entry]
    
    func records(withIDs ids: [Entry.ID]) async throws -> [Entry]
       
    func records(forRecordType type: String) async throws -> [Entry]
    
    func modifyRecords(
        saving recordsToSave: [Entry],
        deleting recordIDsToDelete: [Entry.ID]) async throws -> (saveResults: [Entry], deleteResults: [Entry.ID])
    
    func authenticate() async throws -> AuthenticationStatus
    
    func record(matchingFieldQuery fieldQuery: FieldQuery) async throws -> Entry?
}
