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
            // Cookie check to avoid displaying
            // the splash screen for non-logged in users.
            sessionManager.checkForCookies()
            await sessionManager.getCurrentUser()
        }
    }
}

#Preview {
    AppView()
        .environment(SessionManager())
}
