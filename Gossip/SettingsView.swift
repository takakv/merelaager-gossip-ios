//
//  SettingsView.swift
//  Gossip
//
//  Created by Taaniel Kraavi on 06.07.2025.
//

import SwiftUI

struct SettingsView: View {
    @Environment(SessionManager.self) private var sessionManager
    
    var body: some View {
        Text("Sätted")
        
        Text(sessionManager.currentUser?.username ?? "Anonüümne")
        
        Button {
            sessionManager.signOut()
        } label: {
            Text("Logi välja")
        }
    }
}

#Preview {
    SettingsView()
        .environment(SessionManager())
}
