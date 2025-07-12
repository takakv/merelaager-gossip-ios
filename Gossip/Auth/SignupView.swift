//
//  SignupView.swift
//  Gossip
//
//

import SwiftUI

struct SignupView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Environment(SessionManager.self) private var sessionManager
    
    let token: String
    let givenUsername: String?

    @State private var username = ""
    @State private var password = ""
    @State private var passwordConfirm = ""
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    VStack {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.pink)
                            .padding(.top, 8)
                        
                        Text("Loo konto")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.bottom, 4)
                        
                        Text("Gossipi nägemiseks ja postitamiseks on vajalik konto. Sinu kasutajat näevad ainult kasvatajad.")
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        if let gu = givenUsername {
                            Text("Kasutajanimi".uppercased())
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                                .padding(.top, 20)
                            
                            Text(gu)
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.gray)
                                .background(Color(colorScheme == .dark ? .systemGray5 : .systemGray6))
                                .cornerRadius(10)
                            
                            Text("Sa ei saa oma kasutajanime valida, kuna su konto peab olema anonüümne. Jäta see kasutajanimi meelde.")
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                                .padding(.top, 4)
                        } else {
                            TextField("Kasutajanimi", text: $username)
                                .autocorrectionDisabled()
                                .autocapitalization(.none)
                                .padding(10)
                                .foregroundColor(.gray)
                                .background(Color(colorScheme == .dark ? .systemGray5 : .systemGray6))
                                .cornerRadius(10)
                            
                            Text("Kasutajanimi tohib sisaldada ainult ladina tähestiku tähti, numbreid, punkte ja allkriipse.")
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                                .padding(.top, 4)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        VStack {
                            SecureField("Salasõna", text: $password)
                            Divider()
                            SecureField("Korda salasõna", text: $passwordConfirm)
                        }
                        .padding(10)
                        .foregroundColor(.gray)
                        .background(Color(colorScheme == .dark ? .systemGray5 : .systemGray6))
                        .cornerRadius(10)
                        
                        Text("Salasõna peab olema vähemalt 8 tähemärki pikk ja sisaldama vähemalt ühte numbrit, ühte suurt tähte ja ühte väikest tähte.")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                            .padding(.top, 4)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    VStack {
                        Button {
                            Task { await signUp() }
                        } label: {
                            Text("Loo konto")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 5)
                        }
                        .buttonStyle(.borderedProminent)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .disabled(password.isEmpty || password != passwordConfirm)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    .padding(.bottom, 10)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Tühista") {
                        dismiss()
                    }
                }
            }
        }
    }
}

private extension SignupView {
    func signUp() async {
        do {
            if let gu = givenUsername {
                username = gu
            }
            try await sessionManager.signUp(token: token, username: username, password: password)
            dismiss()
            return
        } catch let error as JSendFailError<SignupFailResponseData> {
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
    SignupView(token: "TOKEN", givenUsername: "anonymouse")
        .environment(SessionManager())
        .tint(.pink)
}
