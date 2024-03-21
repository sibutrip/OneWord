//
//  PlayerView.swift
//  OneWord
//
//  Created by Cory Tripathy on 3/21/24.
//

import SwiftUI

struct PlayerView: View, Alertable {
    typealias RoundViewModelError = RoundViewModel.RoundViewModelError
    @EnvironmentObject var roundViewModel: RoundViewModel
    
    @State var alertError: RoundViewModelError?
    @State var isLoading = false
    @State private var newWord = ""

    var body: some View {
        VStack {
            if roundViewModel.localUser.words.isEmpty {
                TextField("Play any word!", text: $newWord)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        let selectedWord = newWord
                        newWord = ""
                        displayAlertIfFails {
                            try await roundViewModel.playNewWord(selectedWord)
                        }
                    }
            } else {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(roundViewModel.localUser.words) { word in
                            Button(word.description) { 
                                displayAlertIfFails {
                                    try await roundViewModel.playWord(word)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(isLoading)
                        }
                    }
                }
            }
        }
    }
}
