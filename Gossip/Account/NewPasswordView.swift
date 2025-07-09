//
//  NewPasswordView.swift
//  Gossip
//
//

import SwiftUI

struct NewPasswordView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var newPassword = ""
    @State private var repeatPassword = ""
    @State private var errorMessage: String?
    @State private var showSuccessAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    VStack {
                        Image(systemName: "key")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.pink)
                        
                        Text("Uus salasõna")
                            .font(.title)
                            .bold()
                            .padding(.bottom, 12)

                        Text("Võimalusel lase Apple'i „Passwords“ rakendusel salasõna genereerida.")
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 36)
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                    
                    if let errorMessage = errorMessage {
                        Section {
                            Text(errorMessage)
                                .foregroundColor(.red)
                        }
                    }
                    
                    Section {
                        SecureField("Uus salasõna", text: $newPassword)
                            .textContentType(.newPassword)
                        SecureField("Korda salasõna", text: $repeatPassword)
                            .textContentType(.newPassword)
                    } footer: {
                        Text("Salasõna peab olema vähemalt 8 tähemärki pikk ja sisaldama vähemalt ühte numbrit, ühte suurt tähte ja ühte väikest tähte.")
                    }
                }
                .listStyle(.insetGrouped)
                
                VStack {
                    Button {
                        Task {
                            await changePassword()
                        }
                    } label: {
                        Text("Muuda salasõna")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                    }
                    .buttonStyle(.borderedProminent)
                    .cornerRadius(14)
                    .disabled(newPassword.isEmpty || newPassword != repeatPassword)
                }
                .padding(.horizontal, 36)
                .padding(.top, 16)
                .padding(.bottom, 36)
                .background(
                    Color(UIColor.systemGroupedBackground)
                        .ignoresSafeArea(edges: .bottom)
                )
            }
            .background(Color(UIColor.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Tühista") {
                        dismiss()
                    }
                }
            }
            .alert("Salasõna edukalt muudetud.", isPresented: $showSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            }
        }
    }
    
    func isValidPassword(_ password: String) -> Bool {
        let pattern = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).+$"
        return password.range(of: pattern, options: .regularExpression) != nil
    }
    
    func changePassword() async {
        if (newPassword.count < 8) {
            errorMessage = "Salasõna peab olema vähemalt 8 tähemärki pikk!"
        }
        
        if !isValidPassword(newPassword) {
            errorMessage = "Salasõna peab sisaldama vähemalt ühte väikest tähte, ühte suurt tähte ja ühte numbrit!"
        }
        
        do {
            try await AccountService.changePassword(newPassword: newPassword)
            showSuccessAlert = true
        } catch {
            print("DEBUG: \(error)")
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    NewPasswordView()
        .tint(.pink)
}
