//
//  ChannelsView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/22/21.
//

import DistributedChat
import SwiftUI

struct ChannelsView: View {
    let channels: [Channel]
    let controller: ChatController
    
    var body: some View {
        NavigationView {
            List(channels) { channel in
                NavigationLink(destination: ChannelView(channel: channel, controller: controller)) {
                    VStack {
                        Text("#\(channel.displayName)")
                            .font(.headline)
                        if let message = channel.messages.last {
                            Text(message.content)
                                .font(.caption)
                        }
                    }
                }
            }
                .navigationBarTitle("Channels")
        }
    }
}

struct ChatsView_Previews: PreviewProvider {
    static var previews: some View {
        ChannelsView(channels: [], controller: ChatController(transport: MockTransport()))
    }
}
