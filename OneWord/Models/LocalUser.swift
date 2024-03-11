//
//  LocalUser.swift
//  OneWord
//
//  Created by Cory Tripathy on 3/11/24.
//

struct LocalUser {
    let user: User
    var words: [Word]
    
    var id: String { user.id }
    var name: String { user.name }
}
