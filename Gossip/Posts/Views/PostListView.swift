//
//  PostListView.swift
//  Gossip
//
//

import SwiftUI

struct PostListView: View {
    @Environment(SessionManager.self) private var sessionManager
    
    var viewModel: PostsViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.posts.indices, id: \.self) { index in
                let post = viewModel.posts[index]
                
                NavigationLink {
                    PostDetailView(postId: post.id, viewModel: viewModel)
                } label: {
                    ListPost(post: post) {
                        Task {
                            await toggleLike(for: index)
                        }
                    }
                    .onAppear {
                        if post == viewModel.posts.last, viewModel.currentPage <= viewModel.totalPages {
                            viewModel.fetchPosts()
                        }
                    }
                }
            }


            if viewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
        }
        .refreshable {
            viewModel.resetAndFetch()
        }
    }
    
    func toggleLike(for index: Int) async {
        var post = viewModel.posts[index]
        guard let userId = sessionManager.currentUser?.id else { return }

        let wasLiked = post.isLiked

        post.isLiked.toggle()
        post.likeCount += post.isLiked ? 1 : -1
        viewModel.updatePost(post)

        do {
            if (wasLiked) {
                try await PostService.unlikePost(postId: post.id, userId: userId)
                print("DEBUG: Unliked post \(post.id)")
            } else {
                try await PostService.likePost(postId: post.id, userId: userId)
                print("DEBUG: Liked post \(post.id)")
            }
        } catch {
            post.isLiked = wasLiked
            post.likeCount += wasLiked ? 1 : -1
            viewModel.updatePost(post)
            print("Failed to toggle like: \(error)")
        }
    }
}

#Preview {
    let sessionManager = SessionManager()
    PostsView(title: "Kõlakad", viewModel: PostsViewModel(endpoint: ""))
        .environment(sessionManager)
        .task { await sessionManager.getCurrentUser() }
}
