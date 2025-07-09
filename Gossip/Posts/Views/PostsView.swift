//
//  PostsView.swift
//  Gossip
//
//  Created by Taaniel Kraavi on 05.07.2025.
//

import SwiftUI

struct PostsView: View {
    let title: String
    @State var viewModel: PostsViewModel
    
    @State private var showCreatePost = false
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack {
                    if viewModel.posts.isEmpty {
                        Text("Postitusi pole.")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        PostListView(viewModel: viewModel)
                    }

//                    PaginationBar(
//                        currentPage: viewModel.currentPage,
//                        totalPages: viewModel.totalPages,
//                        onPageSelect: { page in
//                            viewModel.goToPage(page)
//                        }
//                    )
                }
                .navigationTitle(title)
                .onAppear {
                    if viewModel.posts.isEmpty {
                        viewModel.resetAndFetch()
                    }
                }
            }

            FloatingCreatePostButton {
                showCreatePost.toggle()
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
