//
//  ChannelSnippetView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/30/21.
//

import SwiftUI
import DistributedChatKit

struct ChannelSnippetView: View {
    let channel: ChatChannel
    
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
                Text(channel.rawDisplayName(with: network))
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

#Preview {
    let messages = Messages()
    let settings = Settings()
    let network = Network(messages: messages)
    
    return ChannelSnippetView(channel: .room("test"))
        .environmentObject(messages)
        .environmentObject(settings)
        .environmentObject(network)
}
