//
//  NewGameView.swift
//  OneWord
//
//  Created by Cory Tripathy on 3/13/24.
//

import SwiftUI

struct NewGameView: View, Alertable {
    typealias LocalUserViewModelError = LocalUserViewModel.LocalUserViewModelError
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var localUserVm: LocalUserViewModel
    @Binding var presentedGames: [Game]
    @State private var groupName = ""
    @State var alertError: LocalUserViewModelError?
    @State var isLoading = false
    var body: some View {
        VStack {
            Text("What should we call this group?")
            TextField("Group name", text: $groupName)
                .textFieldStyle(.roundedBorder)
            Button {
                Task {
                    displayAlertIfFails {
                        let newGroup = try await localUserVm.newGame(withGroupName: groupName)
                        self.localUserVm.games.append(newGroup)
                        presentedGames.append(newGroup)
                    }
                    dismiss()
                }
            } label: {
                createButtonLabel()
            }
            .disabled(groupName.isEmpty)
            .buttonStyle(.borderedProminent)
        }
        .interactiveDismissDisabled(isLoading)
        .padding()
        .navigationTitle("Create New Game")
    }
    
    @ViewBuilder
    func createButtonLabel() -> some View {
        if isLoading {
            ProgressView()
        } else {
            Text("Create!")
        }
    }
}

