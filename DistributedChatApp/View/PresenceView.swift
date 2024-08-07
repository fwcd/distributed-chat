//
//  PresenceView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 2/5/21.
//

import SwiftUI
import DistributedChatKit

struct PresenceView: View {
    let presence: ChatPresence
    
    @EnvironmentObject private var network: Network
    @EnvironmentObject private var navigation: Navigation
    
    var body: some View {
        HStack {
            Image(systemName: "circlebadge.fill")
                .foregroundColor(presence.status.color)
            VStack(alignment: .leading) {
                Text(presence.user.displayName)
                    .multilineTextAlignment(.leading)
                if !presence.info.isEmpty {
                    Text(presence.info)
                        .multilineTextAlignment(.leading)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .contextMenu {
            Button {
                UIPasteboard.general.string = presence.user.id.uuidString
            } label: {
                Label("Copy User ID", systemImage: "doc.on.doc")
            }
            Button {
                UIPasteboard.general.string = presence.user.name
            } label: {
                Label("Copy User Name", systemImage: "doc.on.doc")
            }
            if !presence.info.isEmpty {
                Button {
                    UIPasteboard.general.string = presence.info
                } label: {
                    Label("Copy Status Info", systemImage: "doc.on.doc")
                }
            }
            Button {
                navigation.open(channel: .dm([network.myId, presence.user.id]))
            } label: {
                Label("Open DM channel", systemImage: "at")
            }
        }
    }
}

#Preview {
    let network = Network()
    let navigation = Navigation()
    
    return PresenceView(presence: ChatPresence(user: .init()))
        .environmentObject(network)
        .environmentObject(navigation)
}
