//
//  PostListView.swift
//  Gossip
//
//  Created by Taaniel Kraavi on 09.07.2025.
//

import SwiftUI

struct PostListView: View {
    var viewModel: PostsViewModel

    var body: some View {
        List(viewModel.posts) { post in
            NavigationLink {
                PostDetailView(postId: post.id, viewModel: viewModel)
            } label: {
                ListPost(post: post)
            }
        }
        .refreshable {
            viewModel.fetchPosts()
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width > 100, abs(value.translation.height) < 50, viewModel.currentPage > 1 {
                        viewModel.goToPage(viewModel.currentPage - 1)
                    } else if value.translation.width < -100, abs(value.translation.height) < 50, viewModel.currentPage < viewModel.totalPages {
                        viewModel.goToPage(viewModel.currentPage + 1)
                    }
                }
        )
    }
}

#Preview {
    let sessionManager = SessionManager()
    PostsView(title: "Kõlakad", viewModel: PostsViewModel(endpoint: ""))
        .environment(sessionManager)
        .task { await sessionManager.getCurrentUser() }
}
