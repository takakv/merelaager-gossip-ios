//
//  SessionManager.swift
//  Gossip
//
//

import Foundation

typealias LoginResponse = JSendResponse<UserData>

struct LoginReqBody: Codable {
    let username: String
    let password: String
}

struct SignupReqBody: Codable {
    let token: String
    let username: String
    let password: String
}

struct LoginFailResponseData: Decodable {
    let message: String
}

struct SignupFailResponseData: Decodable {
    let message: String
}

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

@MainActor
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
    
    func login(username: String, password: String) async throws {
        let url = Constants.baseURL.appendingPathComponent("auth/login")
        let body = LoginReqBody(username: username, password: password)
        let _: NoContent = try await Networking.post(url, body: body, failType: LoginFailResponseData.self)
        await getCurrentUser()
    }
    
    func signUp(token: String, username: String, password: String) async throws {
        let url = Constants.baseURL.appendingPathComponent("users")
        let body = SignupReqBody(token: token, username: username, password: password)
        let _: NoContent = try await Networking.post(url, body: body, failType: SignupFailResponseData.self)
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
