//
//  GameDetailView.swift
//  OneWord
//
//  Created by Cory Tripathy on 3/13/24.
//

import SwiftUI

struct GameDetailView: View, Alertable {
    typealias GameViewModelError = GameViewModel.GameViewModelError
    @StateObject var gameVm: GameViewModel
    @State private var showingPreviousRounds = false
    @State var alertError: GameViewModelError?
    @State var isLoading = false
    let game: Game
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Invite Code:")
                    .font(.title2)
                Text(game.inviteCode)
                    .foregroundStyle(.secondary)
            }
            if let currentRound = gameVm.currentRound {
                Text("Current Round")
                HStack { Text("Host:") + Text(currentRound.host.name) }
                HStack { Text("Question:") + Text(currentRound.question.description) }
            }
            Spacer()
        }
        .safeAreaInset(edge: .bottom) {
            Button("New Round") {
                Task {
                    displayAlertIfFails {
                        try await gameVm.startRound()
                    }
                }
            }
        }
        .toolbar {
            Button("Previous Round", systemImage: "clock.arrow.circlepath") {
                showingPreviousRounds = true
            }
        }
        .sheet(isPresented: $showingPreviousRounds) {
            PreviousRounds(with: gameVm.previousRounds)
        }
        .navigationTitle(game.groupName)
        .navigationBarTitleDisplayMode(.large)
        .padding()
    }
    init(localUser: LocalUser, game: Game) {
        self.game = game
        _gameVm = .init(wrappedValue: GameViewModel(
            withUser: localUser,
            game: game,
            database: ProductionDatabase.database))
    }
}

#Preview {
    GameDetailView(localUser: LocalUser(user: User(name: "Cory", systemID: "123"), words: []), game: Game(groupName: "fake group"))
}
