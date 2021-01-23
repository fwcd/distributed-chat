//
//  ChannelsView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/22/21.
//

import DistributedChat
import SwiftUI

struct ChannelsView: View {
    let channelNames: [String?]
    let controller: ChatController
    
    @EnvironmentObject var messages: Messages
    
    var body: some View {
        NavigationView {
            List(channelNames, id: \.self) { channelName in
                NavigationLink(destination: ChannelView(channelName: channelName, controller: controller)) {
                    VStack(alignment: .leading) {
                        Text("#\(channelName ?? globalChannelName)")
                            .font(.headline)
                        if let message = messages[channelName].last {
                            Text(message.content)
                                .font(.subheadline)
                        }
                    }
                }
            }
                .navigationBarTitle("Channels")
        }
    }
}

struct ChatsView_Previews: PreviewProvider {
    @StateObject static var messages = Messages()
    static var previews: some View {
        ChannelsView(channelNames: [], controller: ChatController(transport: MockTransport()))
            .environmentObject(messages)
    }
}
