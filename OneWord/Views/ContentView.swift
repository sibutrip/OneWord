//
//  ContentView.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/18/24.
//

import SwiftUI

struct ContentView: View, Alertable {
    typealias LocalUserViewModelError = LocalUserViewModel.LocalUserViewModelError
    @StateObject var localUserVm = LocalUserViewModel(database: ProductionDatabase.database)
    @State var alertError: LocalUserViewModelError?
    @State var isLoading = false
    @State private var userName = ""
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else {
                if let localUser = localUserVm.localUser {
                    GameOverview(localUser: localUser)
                        .environmentObject(localUserVm)
                } else {
                    if localUserVm.userID != nil {
                        onboarding
                    } else {
                        Text("Connect to iCloud to get started!")
                            .font(.title)
                    }
                }
            }
        }
        .onAppear {
            fetchUserInfo()
        }
    }
    
    func fetchUserInfo() {
        Task {
            displayAlertIfFails {
                try await localUserVm.fetchUserInfo()
            }
        }
    }
    
    func createAccount() {
        Task {
            displayAlertIfFails {
                try await localUserVm.createUser(withName: userName)
            }
        }
    }
    
    var onboarding: some View {
        VStack {
            Text("Welcome to OneWord!")
                .font(.title)
            Text("What should we call you?")
            TextField("Your Name", text: $userName)
                .textFieldStyle(.roundedBorder)
            Button("Join the OneWordCule") {
                createAccount()
            }
            .disabled(userName.isEmpty)
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
