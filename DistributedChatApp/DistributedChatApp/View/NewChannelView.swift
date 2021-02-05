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
    
    @State private var channelNameDraft: String = ""
    
    var body: some View {
        VStack {
            AutoFocusTextField(placeholder: "New Channel", text: $channelNameDraft, onCommit: {
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
        .padding(20)
    }
}

struct NewChannelView_Previews: PreviewProvider {
    static var previews: some View {
        NewChannelView { _ in }
    }
}
