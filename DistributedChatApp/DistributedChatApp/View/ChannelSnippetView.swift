//
//  ChannelSnippetView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/30/21.
//

import SwiftUI
import DistributedChat

struct ChannelSnippetView: View {
    let channel: ChatChannel?
    
    @EnvironmentObject private var messages: Messages
    @EnvironmentObject private var settings: Settings
    @EnvironmentObject private var network: Network
    
    var body: some View {
        HStack {
            if messages.unreadChannels.contains(channel) {
                Image(systemName: "circlebadge.fill")
                    .foregroundColor(.blue)
            } else if case .dm(_) = channel {
                Image(systemName: "at")
            } else {
                Image(systemName: "number")
            }
            VStack(alignment: .leading) {
                Text(channel.displayName(with: network))
                    .font(.headline)
                if let message = messages[channel].last,
                   settings.presentation.showChannelPreviews {
                    PlainMessageView(message: message)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            if messages.pinnedChannels.contains(channel) {
                Spacer()
                Image(systemName: "pin.circle.fill")
            }
        }
    }
}

struct ChannelSnippetView_Previews: PreviewProvider {
    @StateObject static var messages = Messages()
    @StateObject static var settings = Settings()
    @StateObject static var network = Network()
    static var previews: some View {
        ChannelSnippetView(channel: .room("test"))
            .environmentObject(messages)
            .environmentObject(settings)
            .environmentObject(network)
    }
}
