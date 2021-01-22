//
//  ChatsView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/22/21.
//

import SwiftUI

struct ChatsView: View {
    let chats: Chats
    
    var body: some View {
        NavigationView {
            List(chats.chats) { chat in
                NavigationLink(destination: ChatView(chat: chat)) {
                    Text(chat.name)
                        .font(.headline)
                    if let message = chat.messages.last {
                        Text(message.content.text)
                            .font(.caption)
                    }
                }
            }
                .navigationTitle("Chats")
        }
    }
}

struct ChatsView_Previews: PreviewProvider {
    static var previews: some View {
        ChatsView(chats: Chats(chats: []))
    }
}
