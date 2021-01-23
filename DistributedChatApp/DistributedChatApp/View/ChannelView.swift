//
//  ChannelView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/22/21.
//

import DistributedChat
import SwiftUI

struct ChannelView: View {
    let channelName: String?
    let controller: ChatController
    
    @EnvironmentObject private var messages: Messages
    @EnvironmentObject private var settings: Settings
    @State private var focusedMessageId: UUID?
    @State private var replyingToMessageId: UUID?
    @State private var draft: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
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
                                    BubbleMessageView(message: message, isMe: isMe)
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
            if let id = replyingToMessageId, let message = messages[id] {
                HStack {
                    Text("Replying to")
                    PlainMessageView(message: message)
                    Spacer()
                    Button(action: {
                        replyingToMessageId = nil
                    }) {
                        Image(systemName: "xmark.circle")
                    }
                }
            }
            HStack {
                TextField("Message #\(channelName ?? globalChannelName)...", text: $draft, onCommit: sendDraft)
                Button(action: sendDraft) {
                    Text("Send")
                        .fontWeight(.bold)
                }
            }
        }
        .padding(15)
        .navigationBarTitle("#\(channelName ?? globalChannelName)", displayMode: .inline)
        .onReceive(messages.objectWillChange) {
            focusedMessageId = messages[channelName].last?.id
        }
    }
    
    private func sendDraft() {
        if !draft.isEmpty {
            controller.send(content: draft, on: channelName)
            draft = ""
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
    static var previews: some View {
        ChannelView(channelName: nil, controller: controller)
            .environmentObject(messages)
            .environmentObject(settings)
    }
}
