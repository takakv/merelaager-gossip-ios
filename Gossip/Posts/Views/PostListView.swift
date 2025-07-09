//
//  PostListView.swift
//  Gossip
//
//

import SwiftUI

struct PostListView: View {
    var viewModel: PostsViewModel

    var body: some View {
        List {
            ForEach(viewModel.posts) { post in
                NavigationLink {
                    PostDetailView(postId: post.id, viewModel: viewModel)
                } label: {
                    ListPost(post: post)
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
}

#Preview {
    let sessionManager = SessionManager()
    PostsView(title: "Kõlakad", viewModel: PostsViewModel(endpoint: ""))
        .environment(sessionManager)
        .task { await sessionManager.getCurrentUser() }
}
