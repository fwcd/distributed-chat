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
    
    var channelNames: [String?] {
        [nil] + Set(messages.compactMap(\.channelName)).sorted()
    }
    
    init() {}
    
    init(messages: [ChatMessage]) {
        self.messages = messages
    }
    
    subscript(channelName: String?) -> [ChatMessage] {
        messages.filter { $0.channelName == channelName }
    }
}
