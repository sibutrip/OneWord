//
//  GameModel.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/22/24.
//

import Foundation

struct GameModel {
    let id: String
    init() {
        self.id = UUID().uuidString
    }
}
