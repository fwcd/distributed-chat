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
                Text("Delete Locally")
                Image(systemName: "trash")
            }
            Button {
                replyingToMessageId = message.id
            } label: {
                Text("Reply")
                Image(systemName: "arrowshape.turn.up.left.fill")
            }
            if messages.unreadMessageIds.contains(message.id) {
                Button {
                    messages.unreadMessageIds.remove(message.id)
                } label: {
                    Text("Mark as Read")
                    Image(systemName: "circlebadge")
                }
            } else {
                Button {
                    messages.unreadMessageIds.insert(message.id)
                } label: {
                    Text("Mark as Unread")
                    Image(systemName: "circlebadge.fill")
                }
            }
            if !message.displayContent.isEmpty {
                ShareLink(item: message.displayContent) {
                    Text("Share Text")
                    Image(systemName: "square.and.arrow.up")
                }
            }
            ForEach(message.attachments ?? []) { attachment in
                if let url = attachment.content.asURL {
                    ShareLink(item: url.smartResolved) {
                        Text("Share \(attachment.type) (\(attachment.name))")
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            if !message.displayContent.isEmpty {
                Button {
                    UIPasteboard.general.string = message.displayContent
                } label: {
                    Text("Copy Text")
                    Image(systemName: "doc.on.doc")
                }
            }
            Button {
                UIPasteboard.general.string = message.id.uuidString
            } label: {
                Text("Copy Message ID")
                Image(systemName: "doc.on.doc")
            }
            Button {
                UIPasteboard.general.url = URL(string: "distributedchat:///message/\(message.id)")
            } label: {
                Text("Copy Message URL")
                Image(systemName: "doc.on.doc.fill")
            }
            Group {
                Button {
                    UIPasteboard.general.string = message.author.id.uuidString
                } label: {
                    Text("Copy Author ID")
                    Image(systemName: "doc.on.doc")
                }
                Button {
                    UIPasteboard.general.string = message.author.name
                } label: {
                    Text("Copy Author Name")
                    Image(systemName: "doc.on.doc")
                }
                Button {
                    navigation.open(channel: .dm([controller.me.id, message.author.id]))
                } label: {
                    Text("Open DM channel")
                    Image(systemName: "at")
                }
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
