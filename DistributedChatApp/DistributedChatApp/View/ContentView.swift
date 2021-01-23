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
    
    @State private var profileName: String = ""
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
            NearbyView()
                .tabItem {
                    VStack {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                        Text("Nearby")
                    }
                }
            ProfileView(name: $profileName)
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
        .onChange(of: profileName) {
            controller.update(name: $0)
        }
    }
    
    init(controller: ChatController) {
        self.controller = controller
        
        let messages = Messages()
        controller.onAddChatMessage { [unowned messages] message in
            messages.messages.append(message)
        }
        _messages = StateObject(wrappedValue: messages)
    }
}

struct ContentView_Previews: PreviewProvider {
    @StateObject static var settings = Settings()
    static var previews: some View {
        ContentView(controller: ChatController(transport: MockTransport()))
            .environmentObject(settings)
    }
}
