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
    
    @EnvironmentObject var messages: Messages
    @State var draft: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    ForEach(messages[channelName]) { message in
                        // TODO: Chat bubbles and stuff
                        Text("\(message.author.name ?? "<anonymous user>"): \(message.content)")
                    }
                }
                .frame( // Ensure that the VStack actually fills the parent's width
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity,
                    alignment: .topLeading
                )
            }
            HStack {
                TextField("Message #\(channelName ?? globalChannelName)...", text: $draft)
                Button(action: {
                    controller.send(content: draft, on: channelName)
                    draft = ""
                }) {
                    Text("Send")
                        .fontWeight(.bold)
                }
            }
        }
        .padding(15)
        .navigationBarTitle("#\(channelName ?? globalChannelName)", displayMode: .inline)
    }
}

struct ChatView_Previews: PreviewProvider {
    static let alice = ChatUser(name: "Alice")
    static let bob = ChatUser(name: "Bob")
    @StateObject static var messages = Messages(messages: [
        ChatMessage(author: alice, content: "Hello!"),
        ChatMessage(author: bob, content: "Hi!"),
        ChatMessage(author: bob, content: "This is fancy!"),
    ])
    static var previews: some View {
        ChannelView(channelName: nil, controller: ChatController(transport: MockTransport()))
            .environmentObject(messages)
    }
}
