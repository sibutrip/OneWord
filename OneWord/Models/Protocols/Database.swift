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
   
    func records(fromReferences fetchedReference: [FetchedReference]) async throws -> [Entry]
    
    func records(forField field: String) async throws -> [Entry]
    
    func modifyRecords(
        saving recordsToSave: [Entry],
        deleting recordIDsToDelete: [Entry.ID]) async throws -> (saveResults: [Entry], deleteResults: [Entry.ID])
    
    func authenticate() async throws -> AuthenticationStatus
}
