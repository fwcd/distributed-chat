//
//  MessageHistoryView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/24/21.
//

import DistributedChat
import SwiftUI

struct MessageHistoryView: View {
    let channelName: String?
    let controller: ChatController
    @Binding var replyingToMessageId: UUID?
    
    @EnvironmentObject private var messages: Messages
    @EnvironmentObject private var settings: Settings
    @State private var focusedMessageId: UUID?
    
    var body: some View {
        ScrollView(.vertical) {
            ScrollViewReader { scrollView in
                VStack(alignment: .leading) {
                    ForEach(messages[channelName]) { message in
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
                        }
                        
                        switch settings.messageHistoryStyle {
                        case .compact:
                            CompactMessageView(message: message)
                                .contextMenu { menuItems }
                        case .bubbles:
                            let isMe = controller.me.id == message.author.id
                            HStack {
                                if isMe { Spacer() }
                                BubbleMessageView(message: message, isMe: isMe) { repliedToId in
                                    scrollView.scrollTo(repliedToId)
                                }
                                .contextMenu { menuItems }
                                if !isMe { Spacer() }
                            }
                        }
                    }
                }
                .frame( // Ensure that the VStack actually fills the parent's width
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity,
                    alignment: .topLeading
                )
                .onChange(of: focusedMessageId) {
                    if let id = $0 {
                        scrollView.scrollTo(id)
                    }
                }
            }
        }
        .onReceive(messages.objectWillChange) {
            focusedMessageId = messages[channelName].last?.id
        }
    }
}

struct MessageHistoryView_Previews: PreviewProvider {
    static let controller = ChatController(transport: MockTransport())
    static let alice = controller.me
    static let bob = ChatUser(name: "Bob")
    @StateObject static var messages = Messages(messages: [
        ChatMessage(author: alice, content: "Hello!"),
        ChatMessage(author: bob, content: "Hi!"),
        ChatMessage(author: bob, content: "This is fancy!"),
    ])
    @StateObject static var settings = Settings()
    @State static var replyingToMessageId: UUID? = nil
    static var previews: some View {
        MessageHistoryView(channelName: nil, controller: controller, replyingToMessageId: $replyingToMessageId)
            .environmentObject(messages)
            .environmentObject(settings)
    }
}
