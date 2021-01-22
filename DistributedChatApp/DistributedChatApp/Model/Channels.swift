//
//  Channels.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/22/21.
//

import DistributedChat

fileprivate let globalChannelName = "global"

struct Channels {
    var messages: [ChatMessage]
    
    var channels: [Channel] {
        [Channel(name: globalChannelName, messages: messages.filter { $0.channelName == nil })]
            + Dictionary(grouping: messages, by: \.channelName)
                .filter { $0.value != nil }
                .sorted { $0.key < $1.key }
                .map { Channel(name: $0.key, messages: $0.value) }
    }
}
