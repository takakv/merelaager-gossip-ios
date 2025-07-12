//
//  PostsView.swift
//  Gossip
//
//

import SwiftUI

struct PostsView: View {
    @Environment(SessionManager.self) private var sessionManager

    let title: String
    @State var viewModel: PostsViewModel

    @State private var showCreatePost = false
    @State private var postIsOpen = false

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    if viewModel.posts.isEmpty {
                        Text("Postitusi pole.")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        PostListView(viewModel: viewModel)
                    }
                }
                .navigationTitle(title)
                .onAppear {
                    if viewModel.posts.isEmpty {
                        Task {
                            await viewModel.resetAndFetch()
                        }
                    }
                }
                if sessionManager.currentUser?.role != "READER" && !postIsOpen {
                    FloatingCreatePostButton {
                        showCreatePost = true
                    }
                }
            }
        }
        .sheet(isPresented: $showCreatePost) {
            CreatePostView()
        }
    }
}

#Preview {
    let sessionManager = SessionManager()
    PostsView(title: "Kõlakad", viewModel: PostsViewModel(endpoint: ""))
        .environment(sessionManager)
        .task { await sessionManager.getCurrentUser() }
}
