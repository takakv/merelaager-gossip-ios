//
//  PostsView.swift
//  Gossip
//
//  Created by Taaniel Kraavi on 05.07.2025.
//

import SwiftUI

struct PostsView: View {
    let endpoint: String
    let title: String
    
    @State private var viewModel: PostsViewModel

    init(title: String, endpoint: String) {
        self.title = title
        self.endpoint = endpoint
        _viewModel = State(initialValue: PostsViewModel(endpoint: endpoint))
    }
    
    @State private var showCreatePost = false
    
    var body: some View {
        ZStack {
            VStack {
                NavigationStack {
//                    if (viewModel.posts.isEmpty) {
//                        Text("Postitusi pole.")
//                    }
                    
                    List(viewModel.posts) { post in
                        NavigationLink {
                            PostDetailView(postId: post.id, viewModel: viewModel)
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                
                                HStack {
                                    Text(post.title)
                                        .font(.headline)
                                    Text(post.createdAt.formattedLocalShort())
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                }
                                
                                if let imageId = post.imageId, !imageId.isEmpty {
                                    Image(systemName: "photo")
                                        .foregroundColor(.secondary)
                                }
                                
                                Text(post.content ?? "")
                                    // .font(.subheadline)
                                    // .foregroundColor(.secondary)
                                    .lineLimit(3)
                                
                                HStack(spacing: 4) {
                                    Image(systemName: post.isLiked ? "heart.fill" : "heart")
                                        .foregroundColor(post.isLiked ? .pink : .gray)

                                    Text("\(post.likeCount)")
                                        .foregroundColor(post.isLiked ? .pink : .gray)
                                }
                                .font(.system(size: 16))
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .refreshable {
                        viewModel.fetchPosts()
                    }
                    .gesture(
                        DragGesture()
                        .onEnded { value in
                            if value.translation.width > 100 && abs(value.translation.height) < 50 && viewModel.currentPage >= 2 {
                                    viewModel.goToPage(viewModel.currentPage - 1)
                                }
                            if value.translation.width < -100 && abs(value.translation.height) < 50 && viewModel.currentPage + 1 <= viewModel.totalPages {
                                    viewModel.goToPage(viewModel.currentPage + 1)
                                }
                            }
                        )
                    .navigationTitle(title)
                    paginationBar
                }
            }
            .onAppear {
                viewModel.fetchPosts()
            }
            VStack {
                Spacer()
                
                HStack {
                    Spacer()

                    Button(action: {
                        showCreatePost.toggle()
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(Color.pink)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 4)
                    }
                    .padding(.trailing, 24)
                    .padding(.bottom, 24)
                    .accessibilityLabel("Loo postitus")
                }
            }
        }
        .sheet(isPresented: $showCreatePost) {
            CreatePostView()
        }
    }
    
    var paginationBar: some View {
        let current = viewModel.currentPage
        let totalPages = viewModel.totalPages

        if totalPages <= 1 {
            return AnyView(EmptyView())
        }

        let range = max(2, current - 1)...min(totalPages, current + 1)

        return AnyView(
            HStack(spacing: 8) {
                Button(action: {
                    viewModel.goToPage(1)
                }) {
                    Text("1")
                        .fontWeight(current == 1 ? .bold : .regular)
                        .padding(6)
                        .background(current == 1 ? Color.gray.opacity(0.2) : Color.clear)
                        .cornerRadius(5)
                }

                if current > 3 {
                    Text("...")
                        .padding(.horizontal, 4)
                }

                ForEach(Array(range), id: \.self) { page in
                    Button(action: {
                        viewModel.goToPage(page)
                    }) {
                        Text("\(page)")
                            .fontWeight(page == current ? .bold : .regular)
                            .padding(6)
                            .background(page == current ? Color.gray.opacity(0.2) : Color.clear)
                            .cornerRadius(5)
                    }
                }

                Button(action: {
                    viewModel.goToPage(current + 1)
                }) {
                    Image(systemName: "chevron.right")
                }
                .disabled(current >= totalPages)
            }
            .padding()
        )
    }


}

#Preview {
    PostsView(title: "Postitused", endpoint: "")
}
