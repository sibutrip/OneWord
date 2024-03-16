//
//  ContentView.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/18/24.
//

import SwiftUI

struct ContentView: View {
    typealias LocalUserViewModelError = LocalUserViewModel.LocalUserViewModelError
    @StateObject var localUserVm = LocalUserViewModel(database: ProductionDatabase.database)
    @State private var localUserError: LocalUserViewModelError?
    @State private var isLoading = false
    @State private var userName = ""
    private var showingError: Binding<Bool> {
        Binding { localUserError != nil }
        set: { _ in localUserError = nil }
    }
    
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
        .alert(localUserError?.errorTitle ?? "Error", isPresented: showingError) {
            Button("OK") { }
        }
        .onAppear {
            fetchUserInfo()
        }
    }
    
    func fetchUserInfo() {
        isLoading = true
        Task {
            do {
                try await localUserVm.fetchUserInfo()
            } catch let error as LocalUserViewModelError {
                self.localUserError = error
            } catch { fatalError("unknown error") }
            isLoading = false
        }
    }
    
    func createAccount() {
        isLoading = true
        Task {
            do {
                try await localUserVm.createUser(withName: userName)
            } catch let error as LocalUserViewModelError {
                self.localUserError = error
            } catch { fatalError("unknown error") }
            isLoading = false
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
