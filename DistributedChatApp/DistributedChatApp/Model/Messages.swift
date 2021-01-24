//
//  Messages.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/22/21.
//

import Combine
import DistributedChat
import Foundation

class Messages: ObservableObject {
    @Published var autoReadChannelNames: Set<String?> = []
    @Published(persistingTo: "Messages/unread.json") var unreadChannelNames: Set<String?> = []
    @Published(persistingTo: "Messages/messages.json") private(set) var messages: [ChatMessage] = []
    
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
    
    subscript(id: UUID) -> ChatMessage? {
        messages.first { $0.id == id }
    }
    
    func append(message: ChatMessage) {
        messages.append(message)
        if !autoReadChannelNames.contains(message.channelName) {
            unreadChannelNames.insert(message.channelName)
        }
    }
    
    func clear(channelName: String?) {
        messages.removeAll { $0.channelName == channelName }
    }
    
    func deleteMessage(id: UUID) {
        messages.removeAll { $0.id == id }
    }
}
