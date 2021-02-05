//
//  NewChannelView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/30/21.
//

import SwiftUI
import DistributedChat

// TODO: Support creation of DM channels

struct NewChannelView: View {
    let onCommit: (ChatChannel) -> Void
    
    @EnvironmentObject private var network: Network
    @State private var channelNameDraft: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "number")
                AutoFocusTextField(placeholder: "new-room-channel", text: $channelNameDraft, onCommit: {
                    if !channelNameDraft.isEmpty {
                        // Enforce lower-kebab-case
                        let finalDraft = channelNameDraft
                            .lowercased()
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                            .replacingOccurrences(of: " ", with: "-")
                        
                        onCommit(.room(finalDraft))
                    }
                })
                .font(.title2)
            }
            Text("...or add a DM channel:")
                .font(.caption)
            List(network.orderedPresences) { presence in
                Button(action: { onCommit(.dm([network.myId, presence.user.id])) }) {
                    PresenceView(presence: presence)
                }
            }
        }
        .padding(20)
    }
}

struct NewChannelView_Previews: PreviewProvider {
    @StateObject static var network = Network()
    
    static var previews: some View {
        NewChannelView { _ in }
            .environmentObject(network)
    }
}
