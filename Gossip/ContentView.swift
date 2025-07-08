//
//  ContentView.swift
//  Gossip
//
//  Created by Taaniel Kraavi on 04.07.2025.
//

import SwiftUI

struct ContentView: View {
    var role: String
    
    var body: some View {
        TabView {
            Tab("Kõlakad", systemImage: "bubble") {
                PostsView(title: "Kõlakad", endpoint: "")
            }
            Tab("Kõva kumu", systemImage: "heart") {
                PostsView(title: "Kõva kumu", endpoint: "/liked")
            }
            Tab("Minu", systemImage: "rectangle.stack.badge.person.crop") {
                PostsView(title: "Minu postitused", endpoint: "/my")
            }
            if (role == "ADMIN") {
                Tab("Ootel", systemImage: "document.badge.clock") {
                    PostsView(title: "Ootel", endpoint: "/waitlist")
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
    ContentView(role: "ADMIN")
        .environment(SessionManager())
}
