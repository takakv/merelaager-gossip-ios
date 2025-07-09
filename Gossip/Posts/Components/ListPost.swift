//
//  ListPost.swift
//  Gossip
//
//

import SwiftUI

struct ListPost: View {
    let post: Post
    let onLikeToggle: () async -> Void

    var body: some View {
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

            if let content = post.content {
                Text(content)
                    .lineLimit(3)
            }

            HStack(spacing: 4) {
                Button {
                    Task {
                        await onLikeToggle()
                    }
                } label: {
                    Image(systemName: post.isLiked ? "heart.fill" : "heart")
                        .foregroundColor(post.isLiked ? .pink : .gray)
                }
                .buttonStyle(.plain)
                
                Text("\(post.likeCount)")
                    .foregroundColor(post.isLiked ? .pink : .gray)
            }
            .font(.system(size: 16))
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let sessionManager = SessionManager()
    PostsView(title: "Kõlakad", viewModel: PostsViewModel(endpoint: ""))
        .environment(sessionManager)
        .task { await sessionManager.getCurrentUser() }
}
