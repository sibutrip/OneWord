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
    
    @State var alertError: RoundViewModelError?
    @State var isLoading = false
    @State private var newWord = ""
    
    var body: some View {
        VStack {
            Text("Current Round")
            HStack { Text("Host:") + Text(roundViewModel.round.host.name) }
            HStack { Text("Question:") + Text(roundViewModel.round.question.description) }
            Text("Words Played:")
            HStack {
                ForEach(roundViewModel.playedWords) { word in
                    HStack {
                        Text(word.user.name)
                        Spacer()
                        Text(word.description)
                    }
                }
            }
            Spacer()
            if roundViewModel.localUser.words.isEmpty {
                TextField("Play any word!", text: $newWord)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        displayAlertIfFails {
                            try await roundViewModel.addWord(newWord)
                        }
                    }
            } else {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(roundViewModel.localUser.words) { word in
                            Button(word.description) { }
                        }
                    }
                }
            }
        }
        .onAppear {
            displayAlertIfFails {
                try await roundViewModel.fetchWords()
            }
        }
        .toolbar {
            Button("+word") {
                
            }
        }
    }
    init(localUser: LocalUser, round: Round, users: [User]) {
        _roundViewModel = .init(wrappedValue: RoundViewModel(localUser: localUser, round: round, users: users, databaseService: ProductionDatabase.database))
    }
}
