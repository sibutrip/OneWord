//
//  GameVMAlertable.swift
//  OneWord
//
//  Created by Cory Tripathy on 3/18/24.
//

import SwiftUI

protocol Alertable {
    associatedtype CustomError: DescribableError
    var alertError: CustomError? { get nonmutating set }
    var isLoading: Bool { get nonmutating set }
}

extension Alertable {
    var showingAlertError: Binding<Bool> {
        Binding { alertError != nil }
        set: { _ in alertError = nil }
    }
    
    func displayAlertIfFails(for action: @escaping () async throws -> Void) {
        Task {
            isLoading = true
            do { try await action() }
            catch let error as CustomError {
                alertError = error
            } catch { fatalError("unhandled error") }
            isLoading = false
        }
    }
}

fileprivate extension View {
    @ViewBuilder func displaysAlertIfActionFails<Content: Alertable>(for content: Content) -> some View {
        if content.alertError == nil {
            self
        } else {
            self
                .alert(content.alertError?.errorTitle ?? "", isPresented: content.showingAlertError) {
                    Button("OK") { }
                }
        }
    }
}

extension View where Self: Alertable {
    var body: some View {
        body.displaysAlertIfActionFails(for: self)
    }
}
