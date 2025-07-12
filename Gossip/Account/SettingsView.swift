//
//  SettingsView.swift
//  Gossip
//
//

import SwiftUI

struct SettingsView: View {
    @Environment(SessionManager.self) private var sessionManager
    
    @State private var showChangePassword = false
    @State private var showDeleteConfirmation = false
    @State private var username = ""
    
    var body: some View {
        ZStack {
            NavigationStack {
                Form {
                    Section {
                        VStack(alignment: .leading) {
                            Text(sessionManager.currentUser?.username ?? "Anonüümne kasutaja")
                            if (sessionManager.currentUser?.role != "READER") {
                                Text("Postitamine lubatud")
                                    .font(.footnote)
                            } else {
                                Text("Postitamine keelatud")
                                    .font(.footnote)
                            }
                        }
                    } footer: {
                        if (sessionManager.currentUser?.role != "READER") {
                            EmptyView()
                            // Text("Sinu kasutajat näevad ainult kasvatajad.")
                        } else {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Eesti Vabariigi seaduse järgi ei tohi alla 13-aastased lapsed ilma vanema nõusolekuta oma (isiku)andmeid digikeskkonnas jagada.")
                                Text("Kuna meil puudub sinu vanemate nõusolek, ei saa me lubada sul postitada, et sa kogemata isikustavat infot ei jagaks.")
                            }
                        }
                    }
                    
                    Section {
                        Button("Vaheta salasõna") {
                            showChangePassword.toggle()
                        }
                        .tint(.blue)
                        Button("Kustuta konto", role: .destructive) {
                            showDeleteConfirmation = true
                        }
                        .alert("Kustuta konto?", isPresented: $showDeleteConfirmation) {
                            TextField(text: $username) {
                                Text("Kasutajanimi")
                            }
                            Button("Kustuta konto", role: .destructive) {
                                Task {
                                    await deleteAccount()
                                }
                            }
                            .disabled(sessionManager.currentUser?.username != username)
                            Button("Tühista", role: .cancel) { }
                        } message: {
                            Text("Konto kustutamiseks sisesta oma kasutajanimi.")
                        }
                        .tint(.blue)
                    } header: {
                        Text("Konto")
                    } footer: {
                        Text("Koos kontoga kustutatakse ka kõik sinu postitused. Sinu kontot ega postitusi taastada ei saa.")
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
        .sheet(isPresented: $showChangePassword) {
            NewPasswordView()
        }
    }
    
    func deleteAccount() async {
        do {
            try await AccountService.deleteAccount()
            sessionManager.signOut()
        } catch {
            print("DEBUG: \(error)")
        }
    }
}

#Preview {
    SettingsView()
        .environment(SessionManager())
        .tint(.pink)
}
