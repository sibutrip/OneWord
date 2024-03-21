//
//  CurrentRoundView.swift
//  OneWord
//
//  Created by Cory Tripathy on 3/18/24.
//

import SwiftUI

struct CurrentRoundView: View, Alertable {
    typealias RoundViewModelError = RoundViewModel.RoundViewModelError
    @StateObject var roundViewModel: RoundViewModel
    @EnvironmentObject var localUserVm: LocalUserViewModel
    @EnvironmentObject var gameVm: GameViewModel
    
    @Environment(\.refresh) private var refresh
    
    @State var alertError: RoundViewModelError?
    @State var isLoading = false
    var playerIsHost: Bool { roundViewModel.round.host.id == roundViewModel.localUser.id}
    
    var body: some View {
        VStack {
            ScrollView {
                Text("Current Round")
                HStack { Text("Host:") + Text(roundViewModel.round.host.name) }
                HStack { Text("Question:") + Text(roundViewModel.round.question.description) }
                Text("Words Played:")
                ForEach(roundViewModel.playedWords) { word in
                    HStack {
                        Text(word.user.name)
                        Spacer()
                        Text(word.description)
                    }
                }
                Spacer()
            }
            Group {
                if playerIsHost {
                    HostView()
                } else {
                    PlayerView()
                }
            }
        }
        .refreshable {
            displayAlertIfFails {
                try await gameVm.fetchUsersInGame()
                try await gameVm.fetchPreviousRounds()
                try await roundViewModel.fetchWords()
            }
        }
        .onAppear {
            displayAlertIfFails {
                try await roundViewModel.fetchWords()
            }
        }
        .environmentObject(roundViewModel)
        .toolbar {
            Button("+word") {
                let wordDesc = Date().formatted(date: .omitted, time: .shortened)
                let word = Word.new(description: wordDesc, withUser: localUserVm.user!)
                localUserVm.words.append(word)
                Task {
                    do {
                        try await ProductionDatabase.database.add(word, withParent: localUserVm.user!)
                    } catch {
                        fatalError()
                    }
                }
            }
        }
    }
    init(localUser: LocalUser, round: Round, users: [User]) {
        _roundViewModel = .init(wrappedValue: RoundViewModel(localUser: localUser, round: round, users: users, databaseService: ProductionDatabase.database))
    }
}
