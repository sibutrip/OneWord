//
//  PreviousRounds.swift
//  OneWord
//
//  Created by Cory Tripathy on 3/16/24.
//

import SwiftUI

struct PreviousRounds: View {
    let rounds: [Round]
    var body: some View {
        ForEach(rounds) { round in
            HStack {
                Text(round.host.name)
                Spacer()
                Text(round.question.description)
            }
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
