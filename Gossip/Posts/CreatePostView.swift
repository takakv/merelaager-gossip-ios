//
//  CreatePostView.swift
//  Gossip
//
//  Created by Taaniel Kraavi on 06.07.2025.
//

import SwiftUI

struct CreatePostView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title: String = ""
    @State private var content: String = ""
    
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Pealkiri")
                        .font(.headline)
                    TextField("", text: $title)
                        .padding(10)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
                    
                    Text("Sisu")
                        .font(.headline)
                    TextEditor(text: $content)
                        .frame(height: 200)
                        .padding(10)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Postita") {
                        submitPost()
                    }
                    .disabled(isSubmitting)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Tühista") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    func submitPost() {
        guard !title.isEmpty, !content.isEmpty else {
            errorMessage = "Kõik väljad on kohustuslikud!"
            return
        }

        isSubmitting = true
        errorMessage = nil

        PostService.createPost(title: title, content: content) { result in
            DispatchQueue.main.async {
                isSubmitting = false
                switch result {
                case .success:
                    dismiss()
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    CreatePostView()
}
