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

fileprivate let log = Logger(label: "DistributedChatApp.Messages")

class Messages: ObservableObject {
    @Published var autoReadChannelNames: Set<String?> = []
    @Published(persistingTo: "Messages/unread.json") var unread: Set<UUID> = []
    @Published(persistingTo: "Messages/messages.json") private(set) var messages: [UUID: ChatMessage] = [:]
    
    var unreadChannelNames: Set<String?> { Set(unread.compactMap { messages[$0] }.map(\.channelName)) }
    
    var channelNames: [String?] {
        [nil] + messages.values
            .sorted { $0.timestamp > $1.timestamp }
            .compactMap(\.channelName)
            .distinct
    }
    
    init() {}
    
    init(messages: [ChatMessage]) {
        self.messages = Dictionary(messages.map { ($0.id, $0) }, uniquingKeysWith: { k, _ in k })
    }
    
    subscript(channelName: String?) -> [ChatMessage] {
        messages.values
            .filter { $0.channelName == channelName }
            .sorted { $0.timestamp < $1.timestamp }
    }
    
    subscript(id: UUID) -> ChatMessage? {
        messages[id]
    }
    
    func append(message: ChatMessage) {
        var message = message
        
        if let indices = message.attachments?.indices {
            for i in indices {
                message.attachments![i] = storeLocally(attachment: message.attachments![i])
            }
        }
        
        messages[message.id] = message
        if !autoReadChannelNames.contains(message.channelName) {
            unread.insert(message.id)
        }
    }
    
    private func storeLocally(attachment: ChatAttachment) -> ChatAttachment {
        var attachment = attachment
        let baseURL = persistenceFileURL(path: "Attachments/\(attachment.name)")
        let fileName = baseURL.lastPathComponent
        let fileExtension = fileName.contains(".") ? ".\(fileName.split(separator: ".").last!)" : ""
        var url = baseURL
        var i = 1
        
        while (try? url.checkResourceIsReachable()) ?? false {
            url = baseURL.deletingPathExtension().appendingPathExtension("-\(i)\(fileExtension)")
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
        messages = messages.filter { $0.value.channelName != channelName }
    }
    
    func markAsRead(channelName: String?) {
        unread = unread.filter { messages[$0]?.channelName != channelName }
    }
    
    func deleteMessage(id: UUID) {
        messages[id] = nil
    }
}
