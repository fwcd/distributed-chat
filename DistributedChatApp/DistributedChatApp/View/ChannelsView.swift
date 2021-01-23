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
    
    @EnvironmentObject private var messages: Messages
    @State private var channelNameDraft: String = ""
    @State private var channelNameDraftSheetShown: Bool = false
    
    var body: some View {
        NavigationView {
            List(channelNames + ((channelNameDraft.isEmpty || channelNames.contains(channelNameDraft)) ? [] : [channelNameDraft]), id: \.self) { channelName in
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
            .listStyle(PlainListStyle())
            .navigationBarTitle("Channels")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        channelNameDraft = ""
                        channelNameDraftSheetShown = true
                    }) {
                        Image(systemName: "square.and.pencil")
                            .resizable()
                    }
                }
            }
        }
        .sheet(isPresented: $channelNameDraftSheetShown, content: {
            VStack {
                AutoFocusTextField(placeholder: "New Channel", text: $channelNameDraft, onCommit: {
                    if !channelNameDraft.isEmpty {
                        channelNameDraftSheetShown = false
                        
                        // Enforce lower-kebab-case
                        channelNameDraft = channelNameDraft
                            .lowercased()
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                            .replacingOccurrences(of: " ", with: "-")
                    }
                })
                .font(.title2)
            }
            .padding(20)
        })
    }
}

struct ChatsView_Previews: PreviewProvider {
    @StateObject static var messages = Messages()
    static var previews: some View {
        ChannelsView(channelNames: [], controller: ChatController(transport: MockTransport()))
            .environmentObject(messages)
    }
}
