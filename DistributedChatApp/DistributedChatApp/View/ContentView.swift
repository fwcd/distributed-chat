//
//  ContentView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/17/21.
//

import SwiftUI
import DistributedChat

struct ContentView: View {
    private let controller = ChatController(transport: CoreBluetoothTransport())
    
    @State private var chats = Chats(chats: [Chat(name: "#global", messages: [])])
    
    var body: some View {
        TabView {
            ChatsView(chats: chats)
                .tabItem {
                    VStack {
                        Image(systemName: "message.fill")
                        Text("Chats")
                    }
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
