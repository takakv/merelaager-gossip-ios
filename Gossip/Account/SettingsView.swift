//
//  SettingsView.swift
//  Gossip
//
//

import SwiftUI
@preconcurrency import UserNotifications

struct SettingsView: View {
    @Environment(SessionManager.self) private var sessionManager

    @State private var showChangePassword = false
    @State private var showDeleteConfirmation = false
    @State private var username = ""

    @State private var notificationsDenied = false

    var body: some View {
        ZStack {
            NavigationStack {
                Form {
                    Section {
                        VStack(alignment: .leading) {
                            Text(
                                sessionManager.currentUser?.username
                                    ?? "Anonüümne kasutaja"
                            )
                            if sessionManager.currentUser?.role != "READER" {
                                Text("Postitamine lubatud")
                                    .font(.footnote)
                            } else {
                                Text("Postitamine keelatud")
                                    .font(.footnote)
                            }
                        }
                    } footer: {
                        VStack(alignment: .leading, spacing: 8) {
                            if sessionManager.currentUser?.role == "READER" {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(
                                        "Eesti Vabariigi seaduse järgi ei tohi alla 13-aastased lapsed ilma vanema nõusolekuta oma (isiku)andmeid digikeskkonnas jagada."
                                    )
                                    Text(
                                        "Kuna meil puudub sinu vanemate nõusolek, ei saa me lubada sul postitada, et sa kogemata isikustavat infot ei jagaks."
                                    )
                                }
                            }

                            Link(
                                destination: URL(
                                    string:
                                        "https://gossip.merelaager.ee/privaatsuspoliitika"
                                )!
                            ) {
                                HStack(spacing: 4) {
                                    Text("Privaatsuspoliitika")
                                    Image(
                                        systemName: "arrow.up.right.square"
                                    )
                                }
                                .font(.footnote)
                                .foregroundColor(.blue)
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
                        .alert(
                            "Kustuta konto?",
                            isPresented: $showDeleteConfirmation
                        ) {
                            TextField(text: $username) {
                                Text("Kasutajanimi")
                            }
                            Button("Kustuta konto", role: .destructive) {
                                Task {
                                    await deleteAccount()
                                }
                            }
                            .disabled(
                                sessionManager.currentUser?.username != username
                            )
                            Button("Tühista", role: .cancel) {}
                        } message: {
                            Text(
                                "Konto kustutamiseks sisesta oma kasutajanimi."
                            )
                        }
                        .tint(.blue)
                    } header: {
                        Text("Konto")
                    } footer: {
                        Text(
                            "Koos kontoga kustutatakse ka kõik sinu postitused. Sinu kontot ega postitusi taastada ei saa."
                        )
                    }

                    Section {
                        Button("Logi välja") {
                            sessionManager.signOut()
                        }
                        .tint(.blue)
                    } footer: {
                        Text(
                            "Pärast rakendusest väljalogimist pead sa postituste nägemiseks uuesti sisse logima."
                        )
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    }

                    if notificationsDenied {
                        Section {
                            Button("Luba teavitused") {
                                Task {
                                    await openOsNotificationSettings()
                                }
                            }
                            .tint(.blue)
                        } header: {
                            Text("Teavitused")
                        } footer: {
                            Text(
                                "Teavitused saad sisse lülitada iOS-i seadetes."
                            )
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        }
                    }
                }
                .navigationTitle("Konto")
            }
        }
        .sheet(isPresented: $showChangePassword) {
            NewPasswordView()
        }
        .task {
            await checkNotificationPermissionStatus()
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

    func checkNotificationPermissionStatus() async {
        let notificationCenter = UNUserNotificationCenter.current()
        let currentSettings = await notificationCenter.notificationSettings()
        notificationsDenied = currentSettings.authorizationStatus == .denied
    }

    func openOsNotificationSettings() async {
        if notificationsDenied {
            if let url = URL(
                string: UIApplication.openNotificationSettingsURLString
            ) {
                await MainActor.run {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environment(SessionManager())
        .tint(.pink)
}
