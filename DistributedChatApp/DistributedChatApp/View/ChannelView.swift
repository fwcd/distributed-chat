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
    
    var body: some View {
        Text("TODO")
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
