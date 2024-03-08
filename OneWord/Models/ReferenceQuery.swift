//
//  ReferenceQuery.swift
//  OneWord
//
//  Created by Cory Tripathy on 2/7/24.
//

struct ReferenceQuery {
    let childRecordType: String
    let parentRecordType: String
    let parentRecord: Record
    init<Child: ChildRecord>(child: Child.Type, parent: Child.Parent) where Child.Parent: Record{
        self.parentRecord = parent
        self.childRecordType = child.recordType
        self.parentRecordType = Child.Parent.recordType
    }
    init<Child: TwoParentsChildRecord>(child: Child.Type, secondParent: Child.SecondParent) where Child.SecondParent: Record{
        self.parentRecord = secondParent
        self.childRecordType = child.recordType
        self.parentRecordType = Child.SecondParent.recordType
    }
}
