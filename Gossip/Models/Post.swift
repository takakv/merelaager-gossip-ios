//
//  Post.swift
//  Gossip
//
//  Created by Taaniel Kraavi on 05.07.2025.
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

struct Post: Identifiable, Decodable {
    let id: String
    let title: String
    let content: String?
    let imageId: String?
    let createdAt: Date
    let published: Bool
    let likeCount: Int
    let isLiked: Bool
}
