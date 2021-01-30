//
//  ChannelSnippetView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/30/21.
//

import SwiftUI

struct ChannelSnippetView: View {
    let channelName: String?
    
    @EnvironmentObject private var messages: Messages
    @EnvironmentObject private var settings: Settings
    
    var body: some View {
        HStack {
            if messages.unreadChannelNames.contains(channelName) {
                Image(systemName: "circlebadge.fill")
                    .foregroundColor(.blue)
            } else {
                Image(systemName: "number")
            }
            VStack(alignment: .leading) {
                Text(channelName ?? globalChannelName)
                    .font(.headline)
                if let message = messages[channelName].last,
                   settings.presentation.showChannelPreviews {
                    PlainMessageView(message: message)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            if messages.pinnedChannelNames.contains(channelName) {
                Spacer()
                Image(systemName: "pin.circle.fill")
            }
        }
    }
}

struct ChannelSnippetView_Previews: PreviewProvider {
    @StateObject static var messages = Messages()
    @StateObject static var settings = Settings()
    static var previews: some View {
        ChannelSnippetView(channelName: "test")
            .environmentObject(messages)
            .environmentObject(settings)
    }
}
