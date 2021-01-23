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
    @State private var deletingChannelNames: [String?] = []
    @State private var deletionConfirmationShown: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(channelNames + ((channelNameDraft.isEmpty || channelNames.contains(channelNameDraft)) ? [] : [channelNameDraft]), id: \.self) { channelName in
                    NavigationLink(destination: ChannelView(channelName: channelName, controller: controller)) {
                        VStack(alignment: .leading) {
                            Text("#\(channelName ?? globalChannelName)")
                                .font(.headline)
                            if let message = messages[channelName].last {
                                Text("\(message.author.displayName): \(message.content)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .onDelete { indexSet in
                    deletingChannelNames = indexSet.map {
                        $0 < channelNames.count ? channelNames[$0] : nil
                    }
                    deletionConfirmationShown = true
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
        .sheet(isPresented: $channelNameDraftSheetShown) {
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
        }
        .alert(isPresented: $deletionConfirmationShown) {
            Alert(
                title: Text("Are you sure you want to delete all messages in \(deletingChannelNames.map { $0 ?? globalChannelName }.joined(separator: ", "))?"),
                primaryButton: .destructive(Text("Delete")) {
                    for channelName in deletingChannelNames {
                        messages.clear(channelName: channelName)
                    }
                    channelNameDraft = ""
                    deletingChannelNames = []
                },
                secondaryButton: .cancel {
                    deletingChannelNames = []
                }
            )
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
