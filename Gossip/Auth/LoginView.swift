//
//  LoginView.swift
//  Gossip
//
//

import SwiftUI
import Combine

struct SignUpSheetData {
    var showSheet = false
    var givenUsername: String?
}

struct LoginView: View {
    @Environment(SessionManager.self) private var sessionManager
    
    @State private var username = ""
    @State private var password = ""
    @State private var errorMessage: String?
    
    @State private var displayTokenPrompt = false
    @State private var token = ""
    @State var sheetData = SignUpSheetData()
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                Text("Merelaagri gossip")
                    .font(.title)
                    .padding(.bottom, 4)
                
                Text("Logi sisse")
                    .padding(.bottom)
                
                VStack {
                    VStack(spacing: 8) {
                        TextField("Kasutajanimi", text: $username)
                            .autocorrectionDisabled()
                            .autocapitalization(.none)
                        Divider()
                        SecureField("Parool", text: $password)
                    }
                    .padding(12)
                    .foregroundColor(.gray)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                        .padding(.bottom, 0)
                }
                
                VStack {
                    Button {
                        Task {
                            await signIn()
                        }
                    } label: {
                        Text("Logi sisse")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 5)
                    }
                    .buttonStyle(.borderedProminent)
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                .padding(.horizontal)
                .disabled(!formIsValid)
                .opacity(formIsValid ? 1.0 : 0.5)
                .padding(.vertical)
                
                Button {
                    displayTokenPrompt = true
                } label: {
                    HStack(spacing: 3) {
                        Text("Pole kontot?")
                        Text("Loo konto.")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(Color(.systemGray))
                    .font(.subheadline)
                }
                
                Spacer()
            }
        }
        .tint(.pink)
        .alert("Kutse", isPresented: $displayTokenPrompt) {
            TextField(text: $token) {
                Text("Kutsekood")
            }
            .textInputAutocapitalization(.never)
            .onReceive(Just(token)) { newValue in
                let uppercased = newValue.uppercased()
                if (newValue.count == 4) {
                    token.append("-")
                }
                if uppercased != newValue {
                    token = uppercased
                }
                if newValue.count > 9 {
                    token = String(uppercased.prefix(9))
                }
            }
            Button("Tühista", role: .cancel) {
                errorMessage = nil
            }
            Button("Jätka") {
                Task {
                    errorMessage = nil
                    await checkToken()
                }
            }
            .disabled(token.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        } message: {
            Text("Sisesta konto loomiseks vajalik kutsekood, mille said kasvatajatelt.")
        }
        .tint(.blue)
        .sheet(isPresented: $sheetData.showSheet) { [sheetData] in
            SignupView(token: token, givenUsername: sheetData.givenUsername)
        }
        .tint(.pink)
    }
}

private extension LoginView {
    func signIn() async {
        do {
            try await sessionManager.login(username: username, password: password)
        } catch let error as JSendFailError<LoginFailResponseData> {
            print("DEBUG: \(error)")
            errorMessage = error.data.message
            token = ""
        } catch {
            print("DEBUG: \(error)")
            errorMessage = "Viga serveriga ühenduse loomisel."
            token = ""
        }
    }
    
    func checkToken() async {
        do {
            let tokenStatus = try await SignupService.fetchTokenStatus(token: token)
            sheetData.givenUsername = tokenStatus.username
            sheetData.showSheet = true
            return
        } catch let error as JSendFailError<TokenStatusFailData> {
            print("DEBUG: \(error)")
            errorMessage = error.data.message
        } catch {
            print("DEBUG: \(error)")
            errorMessage = "Viga serveriga ühenduse loomisel."
        }
        sheetData.givenUsername = nil
        sheetData.showSheet = false
    }
    
    var formIsValid: Bool {
        return !username.isEmpty && !password.isEmpty
    }
}

#Preview {
    LoginView()
        .environment(SessionManager())
        .tint(.pink)
}
