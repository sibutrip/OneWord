//
//  AuthenticationStatus.swift
//  OneWord
//
//  Created by Cory Tripathy on 3/12/24.
//

enum AuthenticationStatus {
    case available(User.ID), noAccount, accountRestricted, couldNotDetermineAccountStatus, accountTemporarilyUnavailable, iCloudDriveDisabled
}
