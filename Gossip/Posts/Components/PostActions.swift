//
//  PostActions.swift
//  Gossip
//
//

import SwiftUI

struct PostActions: View {
    let post: Post
    let isAdmin: Bool
    let onPublish: () async -> Void
    let onDelete: () -> Void
    let onLikeToggle: () async -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Button {
                Task {
                    await onLikeToggle()
                }
            } label: {
                Image(systemName: post.isLiked ? "heart.fill" : "heart")
                    .foregroundColor(post.isLiked ? .pink : .gray)
                    .font(.system(size: 20))
            }
            
            Text("\(post.likeCount)")
                .foregroundColor(post.isLiked ? .pink : .gray)
                .font(.system(size: 18))
            
            if isAdmin {
                Spacer()
                
                if !post.published {
                    Button("Kinnita") { Task { await onPublish() } }
                    .padding(.trailing, 8)
                    .tint(.green)
                }
                
                Button("Kustuta", role: .destructive, action: onDelete)
            }
        }
        .font(.system(size: 16))
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    
}

#Preview {
    let mockViewModel = PostsViewModel(endpoint: "/mock")
    PostDetailView(postId: "3927cd13-1dae-4fd3-b93d-f5003610fcb2", viewModel: mockViewModel)
        .environment(SessionManager())
}
