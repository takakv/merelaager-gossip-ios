//
//  PostsViewModel.swift
//  Gossip
//
//

import Foundation

@MainActor
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

    func fetchPosts(reset: Bool = false) async {
        guard !isLoading else { return }

        if !reset && currentPage > totalPages { return }

        isLoading = true

        if reset {
            currentPage = 1
        }

        let urlString =
            Constants.baseURL.absoluteString + "/posts" + endpoint
            + "?page=\(currentPage)&limit=25"

        guard let url = URL(string: urlString) else {
            print(URLError(.badURL))
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        do {
            let (data, _) = try await URLSession.shared.data(for: request)

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601WithFractionalSeconds

            let jsendResponse = try decoder.decode(
                JSendResponseTest.self,
                from: data
            )

            if reset {
                posts = jsendResponse.data.posts
            } else {
                posts += jsendResponse.data.posts
            }
            totalPages = jsendResponse.data.totalPages
            currentPage += 1

        } catch {
            DispatchQueue.main.async {
            }
            print("Error fetching posts: \(error)")
        }

        isLoading = false
    }

    func resetAndFetch() async {
        currentPage = 1
        await fetchPosts(reset: true)
    }

    func goToPage(_ page: Int) async {
        guard page >= 1 else { return }
        if page > totalPages { return }

        currentPage = page
        await fetchPosts()
    }
}
