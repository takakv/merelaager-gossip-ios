//
//  LoginView.swift
//  Gossip
//
//

import SwiftUI

struct LoginView: View {
    @Environment(SessionManager.self) private var sessionManager
    
    @State private var username = ""
    @State private var password = ""
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                Text("Merelaagri gossip")
                    .font(.title)
                
                VStack(spacing: 8) {
                    TextField("Kasutajanimi", text: $username)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                        .font(.subheadline)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal, 24)
                    
                    SecureField("Parool", text: $password)
                        .font(.subheadline)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal, 24)
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                
                Button {
                    Task { await signIn() }
                } label: {
                    Text("Logi sisse")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 352, height: 44)
                        .background(Color(.systemPink))
                        .cornerRadius(10)
                }
                .disabled(!formIsValid)
                .opacity(formIsValid ? 1.0 : 0.5)
                .padding(.vertical)
                
                Spacer()
            }
        }
    }
}

private extension LoginView {
    func signIn() async {
        do {
            try await sessionManager.login(username: username, password: password)
        } catch let error as JSendFailError<LoginFailResponseData> {
            print("DEBUG: \(error)")
            errorMessage = error.data.message
        } catch {
            print("DEBUG: \(error)")
            errorMessage = "Viga serveriga ühenduse loomisel."
        }
    }
    
    var formIsValid: Bool {
        return !username.isEmpty && !password.isEmpty
    }
}

#Preview {
    LoginView()
        .environment(SessionManager())
}
