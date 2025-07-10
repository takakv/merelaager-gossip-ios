//
//  AccountService.swift
//  Gossip
//
//

import Foundation

struct ChangePasswordRequestPody: Codable {
    let newPassword: String
}

struct ChangePasswordFailData: Decodable {
    let message: String
}

struct AccountService {
    static func changePassword(newPassword: String) async throws {
        let url = Constants.baseURL.appendingPathComponent("account/change-password")
        let body = ChangePasswordRequestPody(newPassword: newPassword)
        let _: NoContent = try await Networking.post(
            url,
            body: body,
            failType: ChangePasswordFailData.self
        )
    }
    
    static func deleteAccount() async throws {
        let url = Constants.baseURL.appendingPathComponent("account")
        let _: NoContent = try await Networking.delete(url, failType: NoContent.self)
    }
}
