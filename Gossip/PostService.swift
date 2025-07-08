//
//  PostService.swift
//  Gossip
//
//  Created by Taaniel Kraavi on 08.07.2025.
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
    let content: String
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

typealias CreatePostResponse = JSendResponse<CreatePostResponseData>
typealias CreatePostFailResponse = JSendResponse<CreatePostFailResponseData>
typealias PublishPostFailResponse = JSendResponse<PublishPostFailResponseData>
typealias DeletePostFailResponse = JSendResponse<DeletePostFailResponseData>

struct PostService {
    static func fetchPost(postId: String, completion: @escaping (Result<Post, Error>) -> Void) {
        let url = Constants.baseURL.appendingPathComponent("posts/\(postId)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error occurred: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Unexpected response type: \(type(of: response))")
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                do {
                    let response = try JSONDecoder().decode(FetchPostFailResponseData.self, from: data)
                    print("Server error: HTTP \(httpResponse.statusCode)")
                    print(response)
                    completion(.failure(URLError(.badServerResponse)))
                    return
                } catch {
                    print("Decoding error: \(error)")
                    completion(.failure(error))
                    return
                }
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601WithFractionalSeconds
            
            do {
                let response = try decoder.decode(FetchPostResponse.self, from: data)
                completion(.success(response.data.post))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    static func createPost(title: String, content: String, completion: @escaping (Result<CreatePostResponse, Error>) -> Void) {
        let url = Constants.baseURL.appendingPathComponent("posts")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = CreatePostRequestBody(title: title, content: content)
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error occurred: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Unexpected response type: \(type(of: response))")
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                do {
                    let response = try JSONDecoder().decode(CreatePostFailResponse.self, from: data)
                    print("Server error: HTTP \(httpResponse.statusCode)")
                    print(response)
                    completion(.failure(URLError(.badServerResponse)))
                    return
                } catch {
                    print("Decoding error: \(error)")
                    completion(.failure(error))
                    return
                }
            }
            
            do {
                let response = try JSONDecoder().decode(CreatePostResponse.self, from: data)
                completion(.success(response))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    static func publishPost(postId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = Constants.baseURL.appendingPathComponent("posts/\(postId)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = PublishPostRequestBody(published: true)
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error occurred: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Unexpected response type: \(type(of: response))")
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                guard let data = data else {
                    print("No data received")
                    completion(.failure(URLError(.badServerResponse)))
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(PublishPostFailResponse.self, from: data)
                    print("Server error: HTTP \(httpResponse.statusCode)")
                    print(response)
                    completion(.failure(URLError(.badServerResponse)))
                } catch {
                    print("Decoding error: \(error)")
                    completion(.failure(error))
                }
                
                return
            }

            completion(.success(true))
        }.resume()
    }
    
    static func deletePost(postId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = Constants.baseURL.appendingPathComponent("posts/\(postId)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error occurred: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Unexpected response type: \(type(of: response))")
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                guard let data = data else {
                    print("No data received")
                    completion(.failure(URLError(.badServerResponse)))
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(DeletePostFailResponse.self, from: data)
                    print("Server error: HTTP \(httpResponse.statusCode)")
                    print(response)
                    completion(.failure(URLError(.badServerResponse)))
                } catch {
                    print("Decoding error: \(error)")
                    completion(.failure(error))
                }
                
                return
            }

            completion(.success(true))
        }.resume()
    }
}
