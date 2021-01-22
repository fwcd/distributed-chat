//
//  ChannelsView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/22/21.
//

import SwiftUI

struct ChannelsView: View {
    let channels: Channels
    
    var body: some View {
        NavigationView {
            List(channels.channels) { channel in
                NavigationLink(destination: ChannelView(channel: channel)) {
                    Text("#\(channel.name)")
                        .font(.headline)
                    if let message = channel.messages.last {
                        Text(message.content.text)
                            .font(.caption)
                    }
                }
            }
                .navigationBarTitle("Channels")
        }
    }
}

struct ChatsView_Previews: PreviewProvider {
    static var previews: some View {
        ChannelsView(channels: Channels(messages: []))
    }
}
