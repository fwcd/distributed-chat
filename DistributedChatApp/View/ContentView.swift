//
//  ContentView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/17/21.
//

import DistributedChatKit
import SwiftUI

struct ContentView: View {
    let controller: ChatController
    
    @EnvironmentObject private var messages: Messages
    @EnvironmentObject private var navigation: Navigation
    
    var body: some View {
        TabView {
            ChannelsView(channels: messages.channels, controller: controller)
                .tabItem {
                    VStack {
                        Image(systemName: "message.fill")
                        Text("Channels")
                    }
                }
            NetworkView()
                .tabItem {
                    VStack {
                        Image(systemName: "network")
                        Text("Network")
                    }
                }
            ProfileView()
                .tabItem {
                    VStack {
                        Image(systemName: "person.circle.fill")
                        Text("Profile")
                    }
                }
            SettingsView()
                .tabItem {
                    VStack {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
                }
        }
        .environmentObject(messages)
    }
}

#Preview {
    let settings = Settings()
    let messages = Messages()
    let navigation = Navigation()
    let profile = Profile()
    let network = Network(myId: profile.me.id, messages: messages)
    
    return ContentView(controller: ChatController(transport: MockTransport()))
        .environmentObject(settings)
        .environmentObject(messages)
        .environmentObject(navigation)
        .environmentObject(network)
        .environmentObject(profile)
}
