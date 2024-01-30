//
//  ChildRecordFetchedWithParent.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/29/24.
//

import CloudKit

protocol RecordFetchedByID: Record {
    init(from reference: CKRecord.Reference)
}
