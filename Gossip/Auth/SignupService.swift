//
//  SignupService.swift
//  Gossip
//
//

import Foundation

struct TokenStatusData: Decodable {
    let role: String
    let username: String?
}

struct TokenStatusFailData: Decodable {
    let message: String
}

struct SignupService {
    static func fetchTokenStatus(token: String) async throws -> TokenStatusData {
        let url = Constants.baseURL.appendingPathComponent("codes/\(token)")
        let result: TokenStatusData = try await Networking.get(
            url,
            failType: TokenStatusFailData.self
        )
        return result
    }
}
