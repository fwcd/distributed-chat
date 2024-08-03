//
//  MessageHistoryView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/24/21.
//

import DistributedChatKit
import SwiftUI
import UIKit

struct MessageHistoryView: View {
    let channel: ChatChannel?
    let controller: ChatController
    @Binding var replyingToMessageId: UUID?
    
    @EnvironmentObject private var messages: Messages
    @EnvironmentObject private var settings: Settings
    
    var body: some View {
        ScrollView(.vertical) {
            ScrollViewReader { scrollView in
                VStack(alignment: .leading) {
                    ForEach(messages[channel]) { message in
                        MessageView(message: message, controller: controller, replyingToMessageId: $replyingToMessageId) { id in
                            scrollView.scrollTo(id)
                        }
                    }
                }
                .padding(15)
                .frame( // Ensure that the VStack actually fills the parent's width
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity,
                    alignment: .topLeading
                )
                .onAppear {
                    if let id = messages[channel].last?.id {
                        scrollView.scrollTo(id)
                    }
                }
                .onChange(of: messages.messages) {
                    if let id = messages[channel].last?.id {
                        scrollView.scrollTo(id)
                    }
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
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
    
    return MessageHistoryView(channel: nil, controller: controller, replyingToMessageId: .constant(replyingToMessageId))
        .environmentObject(messages)
        .environmentObject(settings)
        .environmentObject(navigation)
}
