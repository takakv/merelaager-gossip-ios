//
//  PostDetailView.swift
//  Gossip
//
//  Created by Taaniel Kraavi on 06.07.2025.
//

import SwiftUI

struct PostDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(SessionManager.self) private var sessionManager
    
    let postId: String
    var viewModel: PostsViewModel

    @State private var post: Post? = nil
    @State private var errorMessage: String? = nil
    @State private var showDeleteConfirmation = false
    
    var postImageURL: URL? {
        guard let imageId = post?.imageId else { return nil }
        return URL(string: "https://merelaager.b-cdn.net/gossip/\(imageId)")
    }
    
    var body: some View {
        VStack {
            if let post = post {
                ScrollView {
                    PostContent(post: post)

                    if let url = postImageURL {
                        PostImage(imageURL: url)
                    }
                    
                    PostActions(
                        post: post,
                        isAdmin: sessionManager.currentUser?.role == "ADMIN",
                        onPublish: publishPost,
                        onDelete: { showDeleteConfirmation = true }
                    )
                    .padding(.top)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            } else {
                Text("No post found")
            }
        }
        .onAppear {
            fetchPost()
        }
        .frame(maxWidth: .infinity)
        .gesture(
            DragGesture()
            .onEnded { value in
                if value.translation.width > 100 && abs(value.translation.height) < 50 {
                        dismiss()
                    }
                }
            )
        .alert("Kustuta postitus?", isPresented: $showDeleteConfirmation) {
            Button("Kustuta", role: .destructive, action: deletePost)
            Button("Tühista", role: .cancel) { }
        } message: {
            Text("Pärast kustutamist ei saa sa postitust enam taastada.")
        }
        // Set the tint to nil for proper styling of the alert dialog.
        .tint(nil)
    }
    
    func fetchPost() {
        PostService.fetchPost(postId: postId) { result in
            switch result {
            case .success(let fetchedPost):
                post = fetchedPost
            case .failure(let error):
                print(error)
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func publishPost() {
        PostService.publishPost(postId: postId) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    viewModel.deletePost(withId: postId)
                    dismiss()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func deletePost() {
        PostService.deletePost(postId: postId) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    viewModel.deletePost(withId: postId)
                    dismiss()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

#Preview {
    let mockViewModel = PostsViewModel(endpoint: "/mock")
    PostDetailView(postId: "3927cd13-1dae-4fd3-b93d-f5003610fcb2", viewModel: mockViewModel)
        .environment(SessionManager())
}
