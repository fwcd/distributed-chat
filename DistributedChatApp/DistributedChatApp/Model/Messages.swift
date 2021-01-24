//
//  Messages.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/22/21.
//

import Combine
import DistributedChat
import Foundation
import Logging

fileprivate let log = Logger(label: "Messages")

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
        var message = message
        
        if let indices = message.attachments?.indices {
            for i in indices {
                message.attachments![i] = storeLocally(attachment: message.attachments![i])
            }
        }
        
        messages.append(message)
        if !autoReadChannelNames.contains(message.channelName) {
            unreadChannelNames.insert(message.channelName)
        }
    }
    
    private func storeLocally(attachment: ChatAttachment) -> ChatAttachment {
        var attachment = attachment
        let baseURL = persistenceFileURL(path: "Attachments/\(attachment.name)")
        var url = baseURL
        var i = 1
        
        while (try? !url.checkResourceIsReachable()) ?? false {
            url = baseURL.appendingPathExtension("-\(i)")
            i += 1
        }
        
        do {
            try Data(contentsOf: attachment.url).write(to: url)
            attachment.url = url
        } catch {
            log.error("Could not store attachment: \(error)")
        }
        
        return attachment
    }
    
    func clear(channelName: String?) {
        messages.removeAll { $0.channelName == channelName }
    }
    
    func deleteMessage(id: UUID) {
        messages.removeAll { $0.id == id }
    }
}
