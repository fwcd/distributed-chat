//
//  NewChannelView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/30/21.
//

import SwiftUI

struct NewChannelView: View {
    let onCommit: (String) -> Void
    
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
                    
                    onCommit(finalDraft)
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
