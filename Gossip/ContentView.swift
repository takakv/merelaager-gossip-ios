//
//  ContentView.swift
//  Gossip
//
//

import SwiftUI

struct ContentView: View {
    @Environment(SessionManager.self) private var sessionManager
    
    var body: some View {
        TabView {
            Tab("Kõlakad", systemImage: "bubble") {
                PostsView(title: "Kõlakad", viewModel: PostsViewModel(endpoint: ""))
            }
            Tab("Kõva kumu", systemImage: "heart") {
                PostsView(title: "Kõva kumu", viewModel: PostsViewModel(endpoint: "/liked"))
            }
            if (sessionManager.currentUser?.role != "READER") {
                Tab("Minu", systemImage: "rectangle.stack.badge.person.crop") {
                    PostsView(title: "Minu postitused", viewModel: PostsViewModel(endpoint: "/my"))
                }
            }
            if (sessionManager.currentUser?.role == "ADMIN") {
                Tab("Ootel", systemImage: "document.badge.clock") {
                    PostsView(title: "Ootel", viewModel: PostsViewModel(endpoint: "/waitlist"))
                }
            }
            Tab("Konto", systemImage: "person.crop.circle") {
                SettingsView()
            }
        }
        .tint(.pink)
    }
}

#Preview {
    let sessionManager = SessionManager()
    ContentView()
        .environment(sessionManager)
        .task { await sessionManager.getCurrentUser() }
}
