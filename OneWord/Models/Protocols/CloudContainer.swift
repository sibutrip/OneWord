//
//  CloudContainer.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/25/24.
//

import CloudKit

#warning("remove ck dependency")
protocol CloudContainer {
    func userRecordID() async throws -> CKRecord.ID
    func accountStatus() async throws -> CKAccountStatus
    var `public`: Database { get }
}
