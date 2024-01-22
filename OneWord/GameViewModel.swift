//
//  GameViewModel.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/22/24.
//

import Foundation

class GameViewModel {
    let localUser: User
    var users: [User] = []
    
    init(withUser user: User) {
        localUser = user
    }
}
