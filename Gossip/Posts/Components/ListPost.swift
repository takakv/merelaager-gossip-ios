//
//  ListPost.swift
//  Gossip
//
//  Created by Taaniel Kraavi on 09.07.2025.
//

import SwiftUI

struct ListPost: View {
    let post: Post

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

#Preview {
    let sessionManager = SessionManager()
    PostsView(title: "Kõlakad", viewModel: PostsViewModel(endpoint: ""))
        .environment(sessionManager)
        .task { await sessionManager.getCurrentUser() }
}
