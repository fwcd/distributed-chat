//
//  ContentView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/17/21.
//

import SwiftUI
import DistributedChat

struct ContentView: View {
    private let controller: ChatController
    @ObservedObject private var messages: Messages
    
    var body: some View {
        TabView {
            ChannelsView(channels: messages.channels)
                .tabItem {
                    VStack {
                        Image(systemName: "message.fill")
                        Text("Channels")
                    }
                }
        }
    }
    
    init(controller: ChatController) {
        let messages = Messages()
        controller.onAddChatMessage { [unowned messages] message in
            messages.messages.append(message)
        }
        
        self.controller = controller
        self.messages = messages
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(controller: ChatController(transport: MockTransport()))
    }
}
