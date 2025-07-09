//
//  PostsViewModel.swift
//  Gossip
//
//

import Foundation

@Observable
class PostsViewModel {
    var posts: [Post] = []
    var currentPage: Int = 1
    var totalPages: Int = 1
    var isLoading: Bool = false
    
    private var endpoint: String
    
    init(endpoint: String) {
        self.endpoint = endpoint
    }
    
    func deletePost(withId id: String) {
        posts.removeAll { $0.id == id }
    }
    
    func updatePost(_ updatedPost: Post) {
        if let index = posts.firstIndex(where: { $0.id == updatedPost.id }) {
            posts[index] = updatedPost
        }
    }
    
    func fetchPosts(reset: Bool = false) {
        guard !isLoading else { return }
        
        if !reset && currentPage > totalPages { return }
        
        isLoading = true

        if reset {
            currentPage = 1
        }
        
        let urlString = Constants.baseURL.absoluteString + "/posts" + endpoint + "?page=\(currentPage)&limit=25"
        guard let url = URL(string: urlString) else {
            print(URLError(.badURL))
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
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
                    if reset {
                        self.posts = jsendResponse.data.posts
                    } else {
                        self.posts += jsendResponse.data.posts
                    }
                    self.totalPages = jsendResponse.data.totalPages
                    self.currentPage += 1
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }.resume()
    }
    
    func resetAndFetch() {
        currentPage = 1
        fetchPosts(reset: true)
    }
    
    func goToPage(_ page: Int) {
        guard page >= 1 else { return }
        if page > totalPages { return }

        currentPage = page
        fetchPosts()
    }
}
