//
//  MessageView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 2/1/21.
//

import DistributedChat
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
            Button(action: {
                messages.deleteMessage(id: message.id)
            }) {
                Text("Delete Locally")
                Image(systemName: "trash")
            }
            Button(action: {
                replyingToMessageId = message.id
            }) {
                Text("Reply")
                Image(systemName: "arrowshape.turn.up.left.fill")
            }
            if messages.unreadMessageIds.contains(message.id) {
                Button(action: {
                    messages.unreadMessageIds.remove(message.id)
                }) {
                    Text("Mark as Read")
                    Image(systemName: "circlebadge")
                }
            } else {
                Button(action: {
                    messages.unreadMessageIds.insert(message.id)
                }) {
                    Text("Mark as Unread")
                    Image(systemName: "circlebadge.fill")
                }
            }
            Button(action: {
                ShareSheet(items: [message.displayContent]).presentIndependently()
            }) {
                Text("Share Text")
                Image(systemName: "square.and.arrow.up")
            }
            ForEach(message.attachments ?? []) { attachment in
                if let url = attachment.content.asURL {
                    Button(action: {
                        ShareSheet(items: [url.smartResolved]).presentIndependently()
                    }) {
                        Text("Share \(attachment.name)")
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            Button(action: {
                UIPasteboard.general.string = message.displayContent
            }) {
                Text("Copy Text")
                Image(systemName: "doc.on.doc")
            }
            Button(action: {
                UIPasteboard.general.string = message.id.uuidString
            }) {
                Text("Copy Message ID")
                Image(systemName: "doc.on.doc")
            }
            Button(action: {
                UIPasteboard.general.url = URL(string: "distributedchat:///message/\(message.id)")
            }) {
                Text("Copy Message URL")
                Image(systemName: "doc.on.doc.fill")
            }
            Group {
                Button(action: {
                    UIPasteboard.general.string = message.author.id.uuidString
                }) {
                    Text("Copy Author ID")
                    Image(systemName: "doc.on.doc")
                }
                Button(action: {
                    UIPasteboard.general.string = message.author.name
                }) {
                    Text("Copy Author Name")
                    Image(systemName: "doc.on.doc")
                }
                Button(action: {
                    navigation.open(channel: .dm([controller.me.id, message.author.id]))
                }) {
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
    }
}

struct MessageView_Previews: PreviewProvider {
    static let controller = ChatController(transport: MockTransport())
    static let alice = controller.me
    static let bob = ChatUser(name: "Bob")
    @StateObject static var messages = Messages(messages: [
        ChatMessage(author: alice, content: "Hello!"),
        ChatMessage(author: bob, content: "Hi!"),
        ChatMessage(author: bob, content: "This is fancy!"),
    ])
    @StateObject static var settings = Settings()
    @StateObject static var navigation = Navigation()
    @State static var replyingToMessageId: UUID? = nil
    static var previews: some View {
        MessageView(message: messages.messages.values.first { $0.content == "Hello!" }!, controller: controller, replyingToMessageId: $replyingToMessageId)
            .environmentObject(messages)
            .environmentObject(settings)
            .environmentObject(navigation)
    }
}
