//
//  JSend.swift
//  Gossip
//
//  Created by Taaniel Kraavi on 08.07.2025.
//

enum JSendStatus: String, Decodable {
    case success
    case fail
}

struct JSendResponse<T: Decodable>: Decodable {
    let status: JSendStatus
    let data: T
    let code: Int?
}

struct JSendError: Decodable {
    let status: String
    let message: String
}
