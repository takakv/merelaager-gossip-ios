//
//  Dates.swift
//  Gossip
//
//

import Foundation

extension JSONDecoder.DateDecodingStrategy {
    // https://stackoverflow.com/q/44682626
    static let iso8601WithFractionalSeconds = custom { decoder in
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = formatter.date(from: dateString) {
            return date
        }
        
        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "Invalid ISO8601 date with fractional seconds: \(dateString)"
        )
    }
}

extension Date {
    func formattedLocalShort() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM @ HH:mm"
        formatter.timeZone = .current
        return formatter.string(from: self)
    }
}
