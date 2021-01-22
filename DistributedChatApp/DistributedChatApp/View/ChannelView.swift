//
//  ChannelView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/22/21.
//

import DistributedChat
import SwiftUI

struct ChannelView: View {
    let channel: Channel
    let controller: ChatController
    
    @State var draft: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(channel.messages) { message in
                        // TODO: Chat bubbles and stuff
                        Text("\(message.author.name ?? "<anonymous user>"): \(message.content)")
                    }
                }
            }
            HStack {
                TextField("Message #\(channel.displayName)...", text: $draft)
                Button(action: {
                    controller.send(content: draft, on: channel.name)
                }) {
                    Text("Send")
                        .fontWeight(.bold)
                }
            }
        }
        .padding(15)
        .navigationBarTitle("#\(channel.displayName)", displayMode: .inline)
    }
}

struct ChatView_Previews: PreviewProvider {
    static let alice = ChatUser(name: "Alice")
    static let bob = ChatUser(name: "Bob")
    static var previews: some View {
        ChannelView(channel: Channel(name: "Test", messages: [
            ChatMessage(author: alice, content: "Hello!"),
            ChatMessage(author: bob, content: "Hi!"),
            ChatMessage(author: bob, content: "This is fancy!"),
        ]), controller: ChatController(transport: MockTransport()))
    }
}
