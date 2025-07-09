//
//  Post.swift
//  Gossip
//
//

import Foundation

struct JSendResponseTest: Decodable {
    let status: String
    let data: PostsData
}

struct FetchPostResponse: Decodable {
    let status: String
    let data: PostDataContainer
}

struct PostsData: Decodable {
    let posts: [Post]
    let currentPage: Int
    let totalPages: Int
}

struct PostDataContainer: Decodable {
    let post: Post
}

struct Post: Identifiable, Decodable, Equatable {
    let id: String
    let title: String
    let content: String?
    let imageId: String?
    let createdAt: Date
    let published: Bool
    let likeCount: Int
    let isLiked: Bool
}
