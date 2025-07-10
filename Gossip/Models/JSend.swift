//
//  JSend.swift
//  Gossip
//
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

struct JSendFailError<F>: Error {
    let statusCode: Int
    let data: F
}
