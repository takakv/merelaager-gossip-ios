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
            if sessionManager.isLoggedIn {
                ContentView()
            } else {
                LoginView()
            }
        }
        .task { await sessionManager.getCurrentUser() }
    }
}

#Preview {
    AppView()
        .environment(SessionManager())
}
