//
//  GameOverview.swift
//  OneWord
//
//  Created by Cory Tripathy on 3/13/24.
//

import SwiftUI

struct GameOverview: View {
    typealias GameViewModelError = GameViewModel.GameViewModelError
    @EnvironmentObject var localUserVm: LocalUserViewModel
    
    let localUser: LocalUser
    
    @State private var isLoading = false
    @State private var gameVmError: GameViewModelError?
    @State private var addingGame = false
    @State private var presentedGames: [Game] = []
    private var showingError: Binding<Bool> {
        Binding { gameVmError != nil }
        set: { _ in gameVmError = nil }
    }
    
    var body: some View {
        NavigationStack(path: $presentedGames) {
            VStack {
                Text("Hello \(localUser.name)")
                    .font(.title)
                ForEach(localUserVm.games) { game in
                    NavigationLink(game.groupName, value: game)
                }
                .navigationDestination(for: Game.self) { game in
                    GameDetailView(game: game)
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
                do {
                    try await localUserVm.fetchGames()
                } catch let error as GameViewModelError {
                    gameVmError = error
                } catch { fatalError() }
            }
        }
        
        .alert(gameVmError?.errorTitle ?? "Error", isPresented: showingError) {
            Button("OK") { }
        }
    }
}
