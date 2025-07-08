//
//  PostsViewModel.swift
//  Gossip
//
//  Created by Taaniel Kraavi on 05.07.2025.
//

import Foundation

@Observable
class PostsViewModel {
    var posts: [Post] = []
    var currentPage: Int = 1
    var totalPages: Int = 1
    
    private var endpoint: String
    
    init(endpoint: String) {
        self.endpoint = endpoint
    }
    
    func deletePost(withId id: String) {
        posts.removeAll { $0.id == id }
    }
    
    func fetchPosts() {
        let urlString = Constants.baseURL.absoluteString + "/posts" + endpoint + "?page=\(currentPage)&limit=25"
        guard let url = URL(string: urlString) else {
            print(URLError(.badURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601WithFractionalSeconds

            do {
                let jsendResponse = try decoder.decode(JSendResponseTest.self, from: data)
                DispatchQueue.main.async {
                    self.posts = jsendResponse.data.posts
                    self.totalPages = jsendResponse.data.totalPages
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }.resume()
    }
    
    func goToPage(_ page: Int) {
        guard page >= 1 else { return }
        if page > totalPages { return }

        currentPage = page
        fetchPosts()
    }
}
