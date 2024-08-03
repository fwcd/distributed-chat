//
//  MessageView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 2/1/21.
//

import DistributedChatKit
import SwiftUI

struct MessageView: View {
    let message: ChatMessage
    let controller: ChatController
    @Binding var replyingToMessageId: UUID?
    var onJumpToMessage: ((UUID) -> Void)? = nil
    
    @EnvironmentObject private var messages: Messages
    @EnvironmentObject private var settings: Settings
    @EnvironmentObject private var navigation: Navigation
    
    var body: some View {
        let menuItems = Group {
            Button {
                messages.deleteMessage(id: message.id)
            } label: {
                Label("Delete Locally", systemImage: "trash")
            }
            Button {
                replyingToMessageId = message.id
            } label: {
                Label("Reply", systemImage: "arrowshape.turn.up.left.fill")
            }
            if messages.unreadMessageIds.contains(message.id) {
                Button {
                    messages.unreadMessageIds.remove(message.id)
                } label: {
                    Label("Mark as Read", systemImage: "circlebadge")
                }
            } else {
                Button {
                    messages.unreadMessageIds.insert(message.id)
                } label: {
                    Label("Mark as Unread", systemImage: "circlebadge.fill")
                }
            }
            if !message.displayContent.isEmpty {
                ShareLink(item: message.displayContent) {
                    Label("Share Text", systemImage: "square.and.arrow.up")
                }
            }
            ForEach(message.attachments ?? []) { attachment in
                if let url = attachment.content.asURL {
                    ShareLink(item: url.smartResolved) {
                        Label("Share \(attachment.type) (\(attachment.name))", systemImage: "square.and.arrow.up")
                    }
                }
            }
            if !message.displayContent.isEmpty {
                Button {
                    UIPasteboard.general.string = message.displayContent
                } label: {
                    Label("Copy Text", systemImage: "doc.on.doc")
                }
            }
            Button {
                UIPasteboard.general.string = message.id.uuidString
            } label: {
                Label("Copy Message ID", systemImage: "doc.on.doc")
            }
            Button {
                UIPasteboard.general.url = URL(string: "distributedchat:///message/\(message.id)")
            } label: {
                Label("Copy Message URL", systemImage: "doc.on.doc.fill")
            }
            Button {
                UIPasteboard.general.string = message.author.id.uuidString
            } label: {
                Label("Copy Author ID", systemImage: "doc.on.doc")
            }
            Button {
                UIPasteboard.general.string = message.author.name
            } label: {
                Label("Copy Author Name", systemImage: "doc.on.doc")
            }
            Button {
                navigation.open(channel: .dm([controller.me.id, message.author.id]))
            } label: {
                Label("Open DM channel", systemImage: "at")
            }
        }
        
        VStack {
            switch settings.presentation.messageHistoryStyle {
            case .compact:
                CompactMessageView(message: message)
                    .contextMenu { menuItems }
            case .bubbles:
                let isMe = controller.me.id == message.author.id
                HStack {
                    if isMe { Spacer() }
                    BubbleMessageView(message: message, isMe: isMe) { repliedToId in
                        onJumpToMessage?(repliedToId)
                    }
                    .contextMenu { menuItems }
                    if !isMe { Spacer() }
                }
            }
        }
        .draggable(message)
    }
}

#Preview {
    let controller = ChatController(transport: MockTransport())
    let alice = controller.me
    let bob = ChatUser(name: "Bob")
    let messages = Messages(messages: [
        ChatMessage(author: alice, content: "Hello!"),
        ChatMessage(author: bob, content: "Hi!"),
        ChatMessage(author: bob, content: "This is fancy!"),
    ])
    let settings = Settings()
    let navigation = Navigation()
    let replyingToMessageId: UUID? = nil
    
    return MessageView(message: messages.messages.values.first { $0.content == "Hello!" }!, controller: controller, replyingToMessageId: .constant(replyingToMessageId))
        .environmentObject(messages)
        .environmentObject(settings)
        .environmentObject(navigation)
}
