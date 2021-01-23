//
//  ContentView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/17/21.
//

import DistributedChat
import SwiftUI

struct ContentView: View {
    private let controller: ChatController
    @ObservedObject private var messages: Messages
    
    var body: some View {
        TabView {
            ChannelsView(channelNames: messages.channelNames, controller: controller)
                .tabItem {
                    VStack {
                        Image(systemName: "message.fill")
                        Text("Channels")
                    }
                }
        }
        .environmentObject(messages)
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
