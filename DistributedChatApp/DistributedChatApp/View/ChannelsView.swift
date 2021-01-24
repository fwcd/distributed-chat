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
    @EnvironmentObject private var settings: Settings
    @EnvironmentObject private var nearby: Nearby
    @State private var channelNameDraft: String = ""
    @State private var channelNameDraftSheetShown: Bool = false
    @State private var deletingChannelNames: [String?] = []
    @State private var deletionConfirmationShown: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                let nearbyCount = nearby.nearbyNodes.count
                HStack {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                    Text("\(nearbyCount) \("user".pluralized(with: nearbyCount)) currently nearby")
                }
                ForEach(channelNames + ((channelNameDraft.isEmpty || channelNames.contains(channelNameDraft)) ? [] : [channelNameDraft]), id: \.self) { channelName in
                    NavigationLink(destination: ChannelView(channelName: channelName, controller: controller)) {
                        HStack {
                            if messages.unreadChannelNames.contains(channelName) {
                                Circle()
                                    .frame(width: 10, height: 10)
                                    .foregroundColor(.blue)
                            } else {
                                Image(systemName: "number")
                            }
                            VStack(alignment: .leading) {
                                Text(channelName ?? globalChannelName)
                                    .font(.headline)
                                if let message = messages[channelName].last,
                                   settings.showChannelPreviews {
                                    PlainMessageView(message: message)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .contextMenu {
                        if messages.unreadChannelNames.contains(channelName) {
                            Button(action: {
                                messages.markAsRead(channelName: channelName)
                            }) {
                                Text("Mark as Read")
                                Image(systemName: "circlebadge")
                            }
                        }
                        Button(action: {
                            deletingChannelNames = [channelName]
                            deletionConfirmationShown = true
                        }) {
                            Text("Delete Locally")
                            Image(systemName: "trash")
                        }
                    }
                }
                .onDelete { indexSet in
                    deletingChannelNames = indexSet.map {
                        $0 < channelNames.count ? channelNames[$0] : channelNameDraft
                    }
                    deletionConfirmationShown = true
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Channels")
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
        .actionSheet(isPresented: $deletionConfirmationShown) {
            ActionSheet(
                title: Text("Are you sure you want to delete ALL messages in \(deletingChannelNames.map { $0 ?? globalChannelName }.joined(separator: ", "))?"),
                message: Text("Messages will only be deleted locally."),
                buttons: [
                    .destructive(Text("Delete")) {
                        for channelName in deletingChannelNames {
                            messages.clear(channelName: channelName)
                        }
                        channelNameDraft = ""
                        deletingChannelNames = []
                    },
                    .cancel {
                        deletingChannelNames = []
                    }
                ]
            )
        }
    }
}

struct ChatsView_Previews: PreviewProvider {
    @StateObject static var messages = Messages()
    @StateObject static var settings = Settings()
    @StateObject static var nearby = Nearby()
    static var previews: some View {
        ChannelsView(channelNames: [], controller: ChatController(transport: MockTransport()))
            .environmentObject(messages)
            .environmentObject(settings)
            .environmentObject(nearby)
    }
}
