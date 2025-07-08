//
//  AuthView.swift
//  Gossip
//
//  Created by Taaniel Kraavi on 05.07.2025.
//

import SwiftUI

struct AuthView: View {
    var sessionManager: SessionManager
    
    @State private var username = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isLoading = false
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Merelaagri gossip")
                .font(.largeTitle)
            
            Form {
                Section {
                    TextField("Kasutajanimi", text: $username)
                        .autocorrectionDisabled()
#if !os(macOS)
                        .textInputAutocapitalization(.never)
#endif
                    
                    SecureField("Parool", text: $password)
                }
                
                if let message = errorMessage {
                    Text(message)
                        .foregroundColor(.red)
                }
                
                Section {
                    Button ("Logi sisse") {
                        Task {
                            await logIn()
                        }
                    }
                }
            }
        }
    }
    
    func logIn() async {
        do {
            try await sessionManager.login(username: username, password: password)
        } catch {
            errorMessage = "Login failed: \(error.localizedDescription)"
        }
    }
}

#Preview {
    AuthView(sessionManager: SessionManager())
}
