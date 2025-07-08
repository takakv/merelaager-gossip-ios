//
//  AppView.swift
//  Gossip
//
//  Created by Taaniel Kraavi on 05.07.2025.
//

import SwiftUI

struct AppView: View {
    @State private var sessionManager = SessionManager()
    
    var body: some View {
        if sessionManager.isLoggedIn {
            ContentView(role: sessionManager.role)
                .environment(sessionManager)
        } else {
            AuthView(sessionManager: sessionManager)
        }
    }
}

#Preview {
    AppView()
}
