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
    
    @StateObject private var profile = Profile()
    @StateObject private var messages: Messages
    
    var body: some View {
        TabView {
            ChannelsView(channelNames: messages.channelNames, controller: controller)
                .tabItem {
                    VStack {
                        Image(systemName: "message.fill")
                        Text("Channels")
                    }
                }
            ProfileView(name: $profile.name)
                .tabItem {
                    VStack {
                        Image(systemName: "person.circle.fill")
                        Text("Profile")
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
        
        _messages = StateObject(wrappedValue: messages)
        self.controller = controller
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(controller: ChatController(transport: MockTransport()))
    }
}
