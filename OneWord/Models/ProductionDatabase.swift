//
//  ProductionDatabase.swift
//  OneWord
//
//  Created by Cory Tripathy on 3/13/24.
//

import CloudKit

class ProductionDatabase {
    private static let ckDatabase = CKContainer(identifier: "iCloud.com.CoryTripathy.OneWord").publicCloudDatabase
    static let database = DatabaseService(withDatabase: ckDatabase)
}
