//
//  ContentView.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/18/24.
//

import SwiftUI

struct ContentView: View {
//    @StateObject var localUserVm = LocalUserViewModel(database: <#T##DatabaseServiceProtocol#>)
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
