//
//  PostService.swift
//  Gossip
//
//

import Foundation

struct CreatePostResponseData: Decodable {
    let postId: String
}

struct CreatePostFailResponseData: Decodable {
    let format: String?
    let user: String?
}

struct CreatePostRequestBody: Codable {
    let title: String
    let content: String?
    let imageId: String?
}

struct PublishPostRequestBody: Codable {
    let published: Bool
}

struct FetchPostFailResponseData: Decodable {
    let postId: String
    let message: String
}

struct PublishPostFailResponseData: Decodable {
    let postId: String
    let message: String
}

struct DeletePostFailResponseData: Decodable {
    let postId: String
    let message: String
}

struct UploadImageResponseData: Decodable {
    let fileName: String
}

struct UploadImageFailResponseData: Decodable {
    let message: String
    let acceptedTypes: [String]?
}

typealias UploadImageResponse = JSendResponse<UploadImageResponseData>
typealias UploadImageFailResponse = JSendResponse<UploadImageFailResponseData>

struct UploadImage {
    let data: Data
    let fileName: String
    let mimeType: String
}

struct PostService {
    static func fetchPost(postId: String) async throws -> Post {
        let url = Constants.baseURL.appendingPathComponent("posts/\(postId)")
        let response: PostDataContainer = try await Networking.get(
            url,
            failType: FetchPostFailResponseData.self
        )
        return response.post
    }
    
    static func uploadImage(_ image: UploadImage, to url: URL) async throws -> UploadImageResponse {
        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(image.fileName)\"\r\n")
        body.append("Content-Type: \(image.mimeType)\r\n\r\n")
        body.append(image.data)
        body.append("\r\n--\(boundary)--\r\n")
        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            print("DEBUG: Did not receive HTTP response")
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let failure = try? JSONDecoder().decode(UploadImageFailResponse.self, from: data)
            print("DEBUG: Image upload failed: \(failure?.data.message ?? "Unknown error")")
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(UploadImageResponse.self, from: data)
    }
    
    static func createPost(title: String, content: String?, image: UploadImage?) async throws -> String {
        var imageId: String? = nil

        if let image = image {
            let uploadURL = Constants.baseURL.appendingPathComponent("posts/images")
            let response = try await uploadImage(image, to: uploadURL)
            imageId = response.data.fileName
        }

        let url = Constants.baseURL.appendingPathComponent("posts")
        let body = CreatePostRequestBody(title: title, content: content, imageId: imageId)
        let response: CreatePostResponseData = try await Networking.post(
            url,
            body: body,
            failType: CreatePostFailResponseData.self
        )
        
        return response.postId
    }
    
    static func publishPost(postId: String) async throws {
        let url = Constants.baseURL.appendingPathComponent("posts/\(postId)")
        let body = PublishPostRequestBody(published: true)
        let _: NoContent = try await Networking.patch(url, body: body, failType: PublishPostFailResponseData.self)
    }
    
    static func deletePost(postId: String) async throws {
        let url = Constants.baseURL.appendingPathComponent("posts/\(postId)")
        let _: NoContent = try await Networking.delete(url, failType: DeletePostFailResponseData.self)
    }
    
    static func likePost(postId: String, userId: String) async throws {
        let url = Constants.baseURL.appendingPathComponent("posts/\(postId)/likes/\(userId)")
        let _: NoContent = try await Networking.put(url, body: NoContent(), failType: DeletePostFailResponseData.self)
    }
    
    static func unlikePost(postId: String, userId: String) async throws {
        let url = Constants.baseURL.appendingPathComponent("posts/\(postId)/likes/\(userId)")
        let _: NoContent = try await Networking.delete(url, failType: DeletePostFailResponseData.self)
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
