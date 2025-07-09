//
//  PostImage.swift
//  Gossip
//
//

import SwiftUI

struct PostImage: View {
    let imageURL: URL
    
    var body: some View {
        AsyncImage(url: imageURL) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: 200)
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(8)
            case .failure:
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 200)
                    .foregroundColor(.gray)
            @unknown default:
                EmptyView()
            }
        }
    }
}

#Preview {
    let mockViewModel = PostsViewModel(endpoint: "")
    PostDetailView(postId: "9357c353-b254-4233-bce8-fd72e16f84ea", viewModel: mockViewModel)
        .environment(SessionManager())
}
