//
//  ContentView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/17/21.
//

import DistributedChat
import SwiftUI

struct ContentView: View {
    let controller: ChatController
    
    @EnvironmentObject private var messages: Messages
    
    var body: some View {
        TabView {
            ChannelsView(channelNames: messages.channelNames, controller: controller)
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

struct ContentView_Previews: PreviewProvider {
    @StateObject static var settings = Settings()
    @StateObject static var messages = Messages()
    @StateObject static var navigation = Navigation()
    @StateObject static var network = Network()
    @StateObject static var profile = Profile()
    static var previews: some View {
        ContentView(controller: ChatController(transport: MockTransport()))
            .environmentObject(settings)
            .environmentObject(messages)
            .environmentObject(navigation)
            .environmentObject(network)
            .environmentObject(profile)
    }
}
