//
//  PreviousRoundsDetail.swift
//  OneWord
//
//  Created by Cory Tripathy on 3/22/24.
//

import SwiftUI

struct PreviousRoundsDetail: View {
    @StateObject var roundVm: RoundViewModel
    var body: some View {
        DisclosureGroup {
            VStack {
                ForEach(roundVm.playedWords.sorted(by: { $0.rank ?? 0 < $1.rank ?? 0 })) { word in
                    if let rank = word.rank {
                        HStack {
                            Text(rank.description)
                            Spacer()
                            VStack {
                                Text(word.description)
                                Text(word.user.name)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        } label: {
            HStack {
                Text(roundVm.round.host.name)
                Spacer()
                Text(roundVm.round.question.description)
            }
        }
    }
    init(localUser: LocalUser, round: Round, users: [User]) {
        _roundVm = .init(wrappedValue: RoundViewModel(localUser: localUser, round: round, users: users, databaseService: ProductionDatabase.database))
    }
}
