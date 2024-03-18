//
//  LocalUser.swift
//  OneWord
//
//  Created by Cory Tripathy on 3/11/24.
//

import Foundation

class LocalUser: ObservableObject {
    let user: User
    @Published var words: [Word]
    
    var id: String { user.id }
    var name: String { user.name }
    
    init(user: User, words: [Word]) {
        self.user = user
        self.words = words
    }
    func addWord(_ word: Word) {
        self.words.append(word)
    }
}
