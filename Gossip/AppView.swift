//
//  AppView.swift
//  Gossip
//
//  Created by Taaniel Kraavi on 05.07.2025.
//

import SwiftUI

struct AppView: View {
    @Environment(SessionManager.self) private var sessionManager
    
    var body: some View {
        Group {
            if sessionManager.isLoggedIn {
                ContentView(role: sessionManager.currentUser?.role)
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
