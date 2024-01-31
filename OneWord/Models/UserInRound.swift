//
//  UserInRound.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/31/24.
//

import Foundation

struct UserInRound {
    let id: String
    let name: String
    var isHost: Bool?
    var rank: Int?
    var word: String?
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}
