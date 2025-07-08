//
//  SessionManager.swift
//  Gossip
//
//  Created by Taaniel Kraavi on 05.07.2025.
//

import Foundation

typealias LoginResponse = JSendResponse<UserData>

struct UserData: Decodable {
    let username: String
    let role: String
}

struct User: Identifiable {
    let id: String
    let username: String
    let role: String
}

@Observable
class SessionManager {
    var isLoggedIn: Bool = false
    var role: String = ""
    
    var currentUser: User?
    
    init() {
        checkLoginState()
    }
    
    func checkLoginState() {
        isLoggedIn = false
        
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies where !cookie.isExpired {
                if cookie.name == "sessionId" {
                    isLoggedIn = true
                }
                if cookie.name == "role" {
                    role = cookie.value
                }
            }
        }
    }
    
    func login(username: String, password: String) async throws {
        let url = Constants.baseURL.appendingPathComponent("auth/login")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body = ["username": username, "password": password]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let config = URLSessionConfiguration.default
        config.httpCookieStorage = HTTPCookieStorage.shared
        let session = URLSession(configuration: config)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.userAuthenticationRequired)
        }
        
        do {
            let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
        } catch {
            print(error)
            throw URLError(.badServerResponse)
        }
        
        checkLoginState()
    }
    
    func signOut() {
        currentUser = nil
        isLoggedIn = false
        role = ""
    }
}

extension HTTPCookie {
    var isExpired: Bool {
        guard let expiresDate = self.expiresDate else { return false }
        return expiresDate < Date()
    }
}
