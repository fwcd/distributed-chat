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
}
