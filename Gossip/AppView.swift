//
//  AppView.swift
//  Gossip
//
//

import SwiftUI

struct AppView: View {
    @Environment(SessionManager.self) private var sessionManager

    var body: some View {
        Group {
            switch sessionManager.appLoadingState {
            case .loading:
                SplashView()
            case .loggedIn:
                ContentView()
            case .loggedOut:
                LoginView()
            }
        }
        .task {
            // Artifical delay for smoother app launch
            try? await Task.sleep(nanoseconds: 200_000_000)
            await sessionManager.getCurrentUser()
        }
    }
}

#Preview {
    AppView()
        .environment(SessionManager())
}
