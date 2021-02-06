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
    @Published var autoReadChannels: Set<ChatChannel?> = []
    @Published(persistingTo: "Messages/unreadMessageIds.json") var unreadMessageIds: Set<UUID> = []
    @Published(persistingTo: "Messages/pinnedChannels.json") private(set) var pinnedChannels: Set<ChatChannel?> = [nil]
    @Published(persistingTo: "Messages/messages.json") private(set) var messages: [UUID: ChatMessage] = [:]
    
    var unreadChannels: Set<ChatChannel?> { Set(unreadMessageIds.compactMap { messages[$0] }.map(\.channel)) }
    var channels: [ChatChannel?] {
        pinnedChannels.sorted { ($0.map { "\($0)" } ?? "") < ($1.map { "\($0)" } ?? "") } + messages.values
            .sorted { $0.timestamp > $1.timestamp }
            .compactMap(\.channel)
            .filter { !pinnedChannels.contains($0) }
            .distinct
    }
    
    var users: Set<ChatUser> {
        Set([UUID: [ChatMessage]](grouping: messages.values, by: { $0.author.id })
            .values
            .compactMap { $0.max { $0.timestamp < $1.timestamp }?.author }) // Use the newest version of the user
    }
    
    init() {}
    
    init(messages: [ChatMessage]) {
        self.messages = Dictionary(messages.map { ($0.id, $0) }, uniquingKeysWith: { k, _ in k })
    }
    
    subscript(channel: ChatChannel?) -> [ChatMessage] {
        messages.values
            .filter { $0.channel == channel }
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
        if !autoReadChannels.contains(message.channel) {
            unreadMessageIds.insert(message.id)
        }
    }
    
    private func storeLocally(attachment: ChatAttachment) -> ChatAttachment {
        var attachment = attachment
        let baseURL = URL(string: "distributedchat:///attachment/\(attachment.name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)")!
        let fileName = baseURL.lastPathComponent
        let fileExtension = fileName.contains(".") ? ".\(fileName.split(separator: ".").last!)" : ""
        var url = baseURL
        var i = 1
        
        while (try? url.smartCheckResourceIsReachable()) ?? false {
            url = baseURL.deletingPathExtension().appendingPathExtension("\(i)\(fileExtension)")
            i += 1
        }
        
        do {
            let data = try attachment.extractedData()
            try data.smartWrite(to: url)
            attachment.content = .url(url)
            attachment.compression = nil
        } catch {
            log.error("Could not store attachment: \(error)")
        }
        
        return attachment
    }
    
    func clear(channel: ChatChannel?) {
        messages = messages.filter { $0.value.channel != channel }
    }
    
    func markAsRead(channel: ChatChannel?) {
        unreadMessageIds = unreadMessageIds.filter { messages[$0]?.channel != channel }
    }
    
    func pin(channel: ChatChannel?) {
        pinnedChannels.insert(channel)
    }
    
    func unpin(channel: ChatChannel?) {
        if channel != nil { // #global cannot be unpinned
            pinnedChannels.remove(channel)
        }
    }
    
    func deleteMessage(id: UUID) {
        messages[id] = nil
    }
}
