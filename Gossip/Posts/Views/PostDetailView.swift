//
//  PostDetailView.swift
//  Gossip
//
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
                        onDelete: { showDeleteConfirmation = true },
                        onLikeToggle: toggleLike
                    )
                    .padding(.top)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            } else {
                VStack {
                    ProgressView("Laen postitust...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task {
            await fetchPost()
        }
        .frame(maxWidth: .infinity)
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width > 100
                        && abs(value.translation.height) < 50
                    {
                        dismiss()
                    }
                }
        )
        .alert("Kustuta postitus?", isPresented: $showDeleteConfirmation) {
            Button("Kustuta", role: .destructive) {
                Task { await deletePost() }
            }
            Button("Tühista", role: .cancel) {}
        } message: {
            Text("Pärast kustutamist ei saa sa postitust enam taastada.")
        }
        // Set the tint to nil for proper styling of the alert dialog.
        .tint(nil)
    }

    func fetchPost() async {
        do {
            let fetchedPost = try await PostService.fetchPost(postId: postId)
            post = fetchedPost
        } catch let error as JSendFailError<FetchPostFailResponseData> {
            errorMessage = error.data.message
        } catch {
            print("DEBUG: \(error)")
            errorMessage = error.localizedDescription
        }
    }

    func publishPost() async {
        do {
            try await PostService.publishPost(postId: postId)
            viewModel.deletePost(withId: postId)
            dismiss()
        } catch {
            print("DEBUG: \(error)")
            errorMessage = error.localizedDescription
        }
    }

    func deletePost() async {
        do {
            try await PostService.deletePost(postId: postId)
            viewModel.deletePost(withId: postId)
            dismiss()
        } catch {
            print("DEBUG: \(error)")
            errorMessage = error.localizedDescription
        }
    }

    func toggleLike() async {
        guard var currentPost = post else { return }
        guard let userId = sessionManager.currentUser?.id else { return }

        let wasLiked = currentPost.isLiked

        currentPost.isLiked.toggle()
        currentPost.likeCount += currentPost.isLiked ? 1 : -1
        post = currentPost

        do {
            if wasLiked {
                try await PostService.unlikePost(postId: postId, userId: userId)
                print("DEBUG: Unliked post \(postId)")
            } else {
                try await PostService.likePost(postId: postId, userId: userId)
                print("DEBUG: Liked post \(postId)")
            }
        } catch {
            currentPost.isLiked = wasLiked
            currentPost.likeCount += wasLiked ? 1 : -1
            post = currentPost

            print("DEBUG: Failed to toggle like - \(error)")
            errorMessage = error.localizedDescription
        }

        viewModel.updatePost(currentPost)
    }
}

#Preview {
    let mockViewModel = PostsViewModel(endpoint: "/mock")
    let sessionManager = SessionManager()
    PostDetailView(
        postId: "3927cd13-1dae-4fd3-b93d-f5003610fcb2",
        viewModel: mockViewModel
    )
    .environment(sessionManager)
    .task { await sessionManager.getCurrentUser() }
}
