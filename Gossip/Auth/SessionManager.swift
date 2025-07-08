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

struct User: Identifiable, Decodable {
    let id: String
    let username: String
    let role: String
}

typealias FetchUserResponse = JSendResponse<User>

@Observable
class SessionManager {
    var isLoggedIn: Bool = false
    var role: String = ""
    
    var currentUser: User?
    
    func checkLoginState() {
        isLoggedIn = false
        
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies where !cookie.isExpired {
                if cookie.name == "sessionId" {
                    isLoggedIn = true
                }
            }
        }
    }
    
    func getCurrentUser() async {
        let url = Constants.baseURL.appendingPathComponent("account")
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("DEBUG: server did not receive an HTTP response")
                print(response)
                return
            }
            
            switch httpResponse.statusCode {
            case 200..<300:
                let loginResponse = try JSONDecoder().decode(FetchUserResponse.self, from: data)
                let userData = loginResponse.data
                
                currentUser = User(id: userData.id, username: userData.username, role: userData.role)
                isLoggedIn = true
                return
            case 401:
                // The user is not logged in.
                return
            case 500..<600:
                print("DEBUG: Server error: \(httpResponse.statusCode)")
                return
            default:
                print("DEBUG: Unexpected status code: \(httpResponse.statusCode)")
                return
            }
        } catch {
            print("DEBUG: Request failed: \(error)")
        }
    }
    
    func login(username: String, password: String) async {
        do {
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
            
//            do {
//                try JSONDecoder().decode(FetchUserResponse.self, from: data)
//            } catch {
//                print(error)
//                throw URLError(.badServerResponse)
//            }
        } catch {
            print("DEBUG: Sign in error: \(error.localizedDescription)")
        }
        
        await getCurrentUser()
    }
    
    func signOut() {
        let cookieStorage = HTTPCookieStorage.shared
        cookieStorage.cookies?.forEach { cookie in
            cookieStorage.deleteCookie(cookie)
        }
        
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
