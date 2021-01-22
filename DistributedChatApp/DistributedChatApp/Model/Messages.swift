//
//  Messages.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/22/21.
//

import Combine
import DistributedChat

class Messages: ObservableObject {
    @Published var messages: [ChatMessage] = []
    
    var channels: [Channel] {
        [Channel(name: nil, messages: messages.filter { $0.channelName == nil })]
            + [String?: [ChatMessage]](grouping: messages, by: \.channelName)
                .compactMap { (k, v) in k.map { (key: $0, value: v) } }
                .sorted { $0.key < $1.key }
                .map { Channel(name: $0.key, messages: $0.value.sorted { $0.timestamp < $1.timestamp }) }
    }
    
    init() {}
}
