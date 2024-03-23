//
//  PreviousRounds.swift
//  OneWord
//
//  Created by Cory Tripathy on 3/16/24.
//

import SwiftUI

struct PreviousRounds: View {
    @EnvironmentObject var roundVm: RoundViewModel
    let rounds: [Round]
    var body: some View {
        ForEach(rounds) { round in
            PreviousRoundsDetail(localUser: roundVm.localUser, round: roundVm.round, users: roundVm.users)
        }
        .navigationTitle("Previous Rounds")
    }
    init(with previousRounds: [Round]) {
        rounds = previousRounds
    }
}

#Preview {
    PreviousRounds(with: [])
}
