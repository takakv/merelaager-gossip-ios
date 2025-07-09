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
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: post.isLiked ? "heart.fill" : "heart")
                .foregroundColor(post.isLiked ? .pink : .gray)
            
            Text("\(post.likeCount)")
                .foregroundColor(post.isLiked ? .pink : .gray)
            
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
    let sessionManager = SessionManager()
    PostsView(title: "Ootel", viewModel: PostsViewModel(endpoint: "/waitlist"))
        .environment(sessionManager)
        .task { await sessionManager.getCurrentUser() }
}
