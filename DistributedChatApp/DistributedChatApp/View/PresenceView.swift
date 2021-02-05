//
//  PresenceView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 2/5/21.
//

import SwiftUI
import DistributedChat

struct PresenceView: View {
    let presence: ChatPresence
    
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
            Button(action: {
                UIPasteboard.general.string = presence.user.id.uuidString
            }) {
                Text("Copy User ID")
                Image(systemName: "doc.on.doc")
            }
            Button(action: {
                UIPasteboard.general.string = presence.user.name
            }) {
                Text("Copy User Name")
                Image(systemName: "doc.on.doc")
            }
            if !presence.info.isEmpty {
                Button(action: {
                    UIPasteboard.general.string = presence.info
                }) {
                    Text("Copy Status Info")
                    Image(systemName: "doc.on.doc")
                }
            }
        }
    }
}

struct PresenceView_Previews: PreviewProvider {
    static var previews: some View {
        PresenceView(presence: ChatPresence(user: .init()))
    }
}
