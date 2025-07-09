//
//  SettingsView.swift
//  Gossip
//
//

import SwiftUI

struct SettingsView: View {
    @Environment(SessionManager.self) private var sessionManager
    
    @State private var password = ""
    @State private var passwordCheck = ""
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading) {
                        Text(sessionManager.currentUser?.username ?? "Anonüümne kasutaja")
                        Text("Postitamine lubatud.")
                            .font(.footnote)
                    }
                }

                Section("Konto") {
                    Button("Vaheta salasõna") { }
                        .tint(.blue)
                    Button("Kustuta konto", role: .destructive) {
                        showDeleteConfirmation = true
                    }
                    .alert("Kustuta konto?", isPresented: $showDeleteConfirmation) {
                        Button("Kustuta", role: .destructive, action: {})
                        Button("Tühista", role: .cancel) { }
                    } message: {
                        Text("Koos kontoga kustutatakse ka kõik sinu postitused. Sinu kontot ega postitusi taastada ei saa.")
                    }
                    .tint(.blue)
                }
                
                Section {
                    Button("Logi välja") {
                        sessionManager.signOut()
                    }
                    .tint(.blue)
                } footer: {
                        Text("Pärast rakendusest väljalogimist pead sa postituste nägemiseks uuesti sisse logima.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
            }
            .navigationTitle("Konto")
        }
    }
}

#Preview {
    SettingsView()
        .environment(SessionManager())
        .tint(.pink)
}
