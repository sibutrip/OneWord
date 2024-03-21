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
    @State private var joiningGame = false
    @State private var creatingOrJoining = false
    @State private var inviteCode = ""
    @State private var presentedGames: [Game] = []
    
    var body: some View {
        NavigationStack(path: $presentedGames) {
            VStack {
                Text("Hello \(localUser.name)!")
                    .font(.title)
                Divider()
                Text("Your groups")
                ForEach(localUserVm.games) { game in
                    NavigationLink(game.groupName, value: game)
                }
                .navigationDestination(for: Game.self) { game in
                    GameDetailView(localUser: localUser, game: game)
                }
                Spacer()
            }
            .toolbar {
                Button("Create or join game", systemImage: "plus") {
                    creatingOrJoining = true
                }
            }
        }
        .alert("Create new game or join existing game?", isPresented: $creatingOrJoining) {
            VStack {
                Button("Create") { addingGame = true }
                Button("Join") { joiningGame = true }
                Button("Cancel", role: .cancel) { }
            }
        }
        .alert("Enter your invite code here!", isPresented: $joiningGame){
            VStack {
                TextField("Invite Code", text: $inviteCode)
                HStack {
                    Button("Join") {
                        displayAlertIfFails {
                            try await localUserVm.joinGame(withInviteCode: inviteCode.uppercased())
                        }
                    }
                    Button("Cancel", role: .cancel) { }
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
