//
//  GossipApp.swift
//  Gossip
//
//

import SwiftUI

@main
struct GossipApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var sessionManager = SessionManager()
    
    init() {
        appDelegate.sessionManager = sessionManager
    }

    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(sessionManager)
        }
    }
}
