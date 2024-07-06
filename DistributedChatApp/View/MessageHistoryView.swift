//
//  MessageHistoryView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/24/21.
//

import DistributedChat
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
    @StateObject static var navigation = Navigation()
    @State static var replyingToMessageId: UUID? = nil
    static var previews: some View {
        MessageHistoryView(channel: nil, controller: controller, replyingToMessageId: $replyingToMessageId)
            .environmentObject(messages)
            .environmentObject(settings)
            .environmentObject(navigation)
    }
}
