//
//  HostView.swift
//  OneWord
//
//  Created by Cory Tripathy on 3/21/24.
//

import SwiftUI

struct HostView: View, Alertable {
    typealias RoundViewModelError = RoundViewModel.RoundViewModelError
    @EnvironmentObject var roundVm: RoundViewModel
    @EnvironmentObject var gameVm: GameViewModel

    @State var isLoading = false
    @State var alertError: RoundViewModelError?
    
    @State private var isScoring = false
    @State private var currentNum = 1
    var wordsAreScored: Bool {
        !roundVm.playedWords
            .map { $0.rank }
            .contains(where: {$0 == nil} )
        && !roundVm.playedWords.isEmpty
    }
    
    var body: some View {
        VStack {
            Button("Score") { isScoring = true }
                .buttonStyle(.borderedProminent)
        }
        .sheet(isPresented: $isScoring) {
            NavigationStack {
                Text(roundVm.round.question.description)
                    .font(.title2)
                List {
                    ForEach($roundVm.playedWords) { $word in
                        Button {
                            if let wordRank = word.rank {
                                for otherWord in roundVm.playedWords {
                                    guard let otherWordRank = otherWord.rank else { continue }
                                    if otherWordRank > wordRank {
                                        var otherWord = otherWord
                                        otherWord.rank = nil
                                        currentNum -= 1
                                        roundVm.playedWords = roundVm.playedWords.map {$0.id == otherWord.id ? otherWord : $0}
                                    }
                                }
                                word.rank = nil
                                currentNum -= 1
                            } else {
                                word.rank = currentNum
                                currentNum += 1
                                
                            }
                        } label: {
                            HStack {
                                if let rank = word.rank {
                                    Text(rank.description)
                                        .font(.title)
                                } else {
                                    Image(systemName: "square.dotted")
                                        .font(.title)
                                }
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
                .toolbar { Button("Cancel") { isScoring = false } }
                .navigationTitle("Scoring")
                .navigationBarTitleDisplayMode(.inline)
            }
            .onAppear {
                currentNum = roundVm.playedWords
                    .compactMap { $0.rank }
                    .count + 1
            }
            .safeAreaInset(edge: .bottom) {
                Button {
                    displayAlertIfFails {
                        try await roundVm.submitWordScores()
                        try await gameVm.startRound()
                        isScoring = false
                    }
                } label: {
                    if isLoading { ProgressView() } else { Text("Submit") }
                }
                .disabled(!wordsAreScored)
                .buttonStyle(.borderedProminent)
            }
        }
    }
}
