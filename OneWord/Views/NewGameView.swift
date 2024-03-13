//
//  NewGameView.swift
//  OneWord
//
//  Created by Cory Tripathy on 3/13/24.
//

import SwiftUI

struct NewGameView: View {
    @EnvironmentObject var localUserVm: LocalUserViewModel
    @Binding var presentedGames: [Game]
    var body: some View {
        Button("Add") {
            let game = Game(groupName: "my great group")
            localUserVm.games.append(game)
            presentedGames = [game]
        }
    }
}
