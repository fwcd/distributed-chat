//
//  ChannelView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/22/21.
//

import DistributedChatKit
import SwiftUI

struct ChannelView: View {
    let channel: ChatChannel
    let controller: ChatController
    
    @EnvironmentObject private var messages: Messages
    @EnvironmentObject private var network: Network
    @State private var replyingToMessageId: UUID?
    
    var body: some View {
        VStack(alignment: .leading) {
            MessageHistoryView(channel: channel, controller: controller, replyingToMessageId: $replyingToMessageId)
            MessageComposeView(channel: channel, controller: controller, replyingToMessageId: $replyingToMessageId)
        }
        .padding(15)
        .navigationTitle(channel.displayName(with: network))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            messages.autoReadChannels.insert(channel)
            messages.markAsRead(channel: channel)
        }
        .onDisappear {
            messages.autoReadChannels.remove(channel)
        }
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
    let network = Network(myId: controller.me.id, messages: messages)
    let navigation = Navigation()
    
    return ChannelView(channel: .global, controller: controller)
        .environmentObject(messages)
        .environmentObject(settings)
        .environmentObject(network)
        .environmentObject(navigation)
}
