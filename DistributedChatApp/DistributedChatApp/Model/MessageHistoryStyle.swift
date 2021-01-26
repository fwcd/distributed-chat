//
//  MessageHistoryStyle.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/23/21.
//

enum MessageHistoryStyle: String, CaseIterable, Hashable, CustomStringConvertible, Codable {
    case compact = "Compact"
    case bubbles = "Bubbles"
    
    var description: String { rawValue }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        if let value = MessageHistoryStyle(rawValue: rawValue) {
            self = value
        } else {
            throw PersistenceError.invalidValue("'\(rawValue)' is not a valid MessageHistoryStyle!")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
