//
//  GameDetailView.swift
//  OneWord
//
//  Created by Cory Tripathy on 3/13/24.
//

import SwiftUI

struct GameDetailView: View {
    let game: Game
    var body: some View {
        Text(game.groupName)
    }
}

#Preview {
    GameDetailView(game: Game(groupName: "fake group"))
}
