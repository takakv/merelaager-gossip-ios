//
//  GossipApp.swift
//  Gossip
//
//

import SwiftUI

@main
struct GossipApp: App {
    @State private var sessionManager = SessionManager()

    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(sessionManager)
        }
    }
}
