//
//  ContentView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/17/21.
//

import SwiftUI
import DistributedChat

struct ContentView: View {
    let controller: ChatController
    
    @State private var channels = Channels(messages: [])
    
    var body: some View {
        TabView {
            ChannelsView(channels: channels)
                .tabItem {
                    VStack {
                        Image(systemName: "message.fill")
                        Text("Channels")
                    }
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(controller: ChatController(transport: MockTransport()))
    }
}
