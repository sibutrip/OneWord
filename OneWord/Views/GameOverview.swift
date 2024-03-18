//
//  GameOverview.swift
//  OneWord
//
//  Created by Cory Tripathy on 3/13/24.
//

import SwiftUI

struct GameOverview: View, Alertable {
    typealias GameViewModelError = GameViewModel.GameViewModelError
    @EnvironmentObject var localUserVm: LocalUserViewModel
    
    let localUser: LocalUser
    
    @State var isLoading = false
    @State var alertError: GameViewModelError?
    @State private var addingGame = false
    @State private var presentedGames: [Game] = []
    
    var body: some View {
        NavigationStack(path: $presentedGames) {
            VStack {
                Text("Hello \(localUser.name)!")
                    .font(.title)
                ForEach(localUserVm.games) { game in
                    NavigationLink(game.groupName, value: game)
                }
                .navigationDestination(for: Game.self) { game in
                    GameDetailView(localUser: localUser, game: game)
                }
            }
            .toolbar {
                Button("New Game", systemImage: "plus") {
                    addingGame = true
                }
            }
        }
        .sheet(isPresented: $addingGame) {
            NewGameView(presentedGames: $presentedGames)
        }
        
        .onAppear {
            Task {
                displayAlertIfFails {
                    try await localUserVm.fetchGames()
                }
            }
        }
    }
}
