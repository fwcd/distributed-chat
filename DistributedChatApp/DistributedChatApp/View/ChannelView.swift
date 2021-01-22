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
    
    @State var draft: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(channel.messages) { message in
                        // TODO: Chat bubbles and stuff
                        Text("\(message.author.name ?? "<anonymous user>"): \(message.content.text)")
                    }
                }
            }
            HStack {
                TextField("Message #\(channel.name)...", text: $draft)
                Button(action: {
                    // TODO: Do something
                }) {
                    Text("Send")
                        .fontWeight(.bold)
                }
            }
        }
        .padding(15)
    }
}

struct ChatView_Previews: PreviewProvider {
    static let alice = ChatUser(name: "Alice")
    static let bob = ChatUser(name: "Bob")
    static var previews: some View {
        ChannelView(channel: Channel(name: "Test", messages: [
            ChatMessage(author: alice, content: .init(text: "Hello!")),
            ChatMessage(author: bob, content: .init(text: "Hi!")),
            ChatMessage(author: bob, content: .init(text: "This is fancy!")),
        ]))
    }
}
