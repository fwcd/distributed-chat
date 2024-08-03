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

struct ChatView_Previews: PreviewProvider {
    static let controller = ChatController(transport: MockTransport())
    static let alice = controller.me
    static let bob = ChatUser(name: "Bob")
    @StateObject static var messages = Messages(messages: [
        ChatMessage(author: alice, content: "Hello!"),
        ChatMessage(author: bob, content: "Hi!"),
        ChatMessage(author: bob, content: "This is fancy!"),
    ])
    @StateObject static var settings = Settings()
    @StateObject static var network = Network(myId: controller.me.id, messages: messages)
    @StateObject static var navigation = Navigation()
    static var previews: some View {
        ChannelView(channel: .global, controller: controller)
            .environmentObject(messages)
            .environmentObject(settings)
            .environmentObject(network)
            .environmentObject(navigation)
    }
}
