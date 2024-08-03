//
//  ChannelsView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/22/21.
//

import DistributedChatKit
import SwiftUI

struct ChannelsView: View {
    let channels: [ChatChannel]
    let controller: ChatController
    
    @EnvironmentObject private var messages: Messages
    @EnvironmentObject private var navigation: Navigation
    @EnvironmentObject private var settings: Settings
    @EnvironmentObject private var network: Network
    @State private var newChannels: [ChatChannel] = []
    @State private var channelDraftSheetShown: Bool = false
    @State private var deletingChannels: [ChatChannel] = []
    @State private var deletionConfirmationShown: Bool = false
    
    private var allChannels: [ChatChannel] {
        channels + newChannels.filter { !channels.contains($0) }
    }
    
    var body: some View {
        NavigationSplitView {
            List(selection: $navigation.activeChannel) {
                let nearbyCount = network.nearbyUsers.count
                let reachableCount = network.presences.filter { $0.key != controller.me.id }.count
                HStack {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                    Text("\(reachableCount) \("user".pluralized(with: reachableCount)) reachable, \(nearbyCount) \("user".pluralized(with: nearbyCount)) nearby")
                }
                ForEach(allChannels, id: \.self) { channel in
                    NavigationLink(value: channel) {
                        ChannelSnippetView(channel: channel)
                    }
                    .draggable(channel)
                    .contextMenu {
                        Button {
                            deletingChannels = [channel]
                            deletionConfirmationShown = true
                        } label: {
                            Label("Delete Locally", systemImage: "trash")
                        }
                        if messages.unreadChannels.contains(channel) {
                            Button {
                                messages.markAsRead(channel: channel)
                            } label: {
                                Label("Mark as Read", systemImage: "circlebadge")
                            }
                        }
                        if !messages.pinnedChannels.contains(channel) {
                            Button {
                                messages.pin(channel: channel)
                            } label: {
                                Label("Pin", systemImage: "pin.fill")
                            }
                        } else if channel != .global {
                            Button {
                                messages.unpin(channel: channel)
                            } label: {
                                Label("Unpin", systemImage: "pin.slash.fill")
                            }
                        }
                        Button {
                            UIPasteboard.general.string = channel.displayName(with: network)
                        } label: {
                            Label("Copy Channel Name", systemImage: "doc.on.doc")
                        }
                        Button {
                            UIPasteboard.general.url = URL(channel)
                        } label: {
                            Label("Copy Channel URL", systemImage: "doc.on.doc.fill")
                        }
                    }
                }
                .onDelete { indexSet in
                    deletingChannels = indexSet.map { allChannels[$0] }
                    deletionConfirmationShown = true
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Channels")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        channelDraftSheetShown = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .resizable()
                    }
                }
            }
        } detail: {
            Group {
                if let channel = navigation.activeChannel {
                    ChannelView(channel: channel, controller: controller)
                }
            }
        }
        .sheet(isPresented: $channelDraftSheetShown) {
            NewChannelView {
                channelDraftSheetShown = false
                newChannels = [$0]
            }
        }
        .actionSheet(isPresented: $deletionConfirmationShown) {
            ActionSheet(
                title: Text("Are you sure you want to delete ALL messages in \(deletingChannels.map { $0.displayName(with: network) }.joined(separator: ", "))?"),
                message: Text("Messages will only be deleted locally."),
                buttons: [
                    .destructive(Text("Delete")) {
                        for channel in deletingChannels {
                            messages.clear(channel: channel)
                        }
                        newChannels.removeAll(where: deletingChannels.contains)
                        deletingChannels = []
                    },
                    .cancel {
                        deletingChannels = []
                    }
                ]
            )
        }
        .onReceive(navigation.$activeChannel) {
            if case let channel?? = $0, !allChannels.contains(channel) {
                newChannels = [channel]
            }
        }
    }
}

#Preview {
    let messages = Messages()
    let navigation = Navigation()
    let settings = Settings()
    let network = Network(messages: messages)
    
    return ChannelsView(channels: [], controller: ChatController(transport: MockTransport()))
        .environmentObject(messages)
        .environmentObject(navigation)
        .environmentObject(settings)
        .environmentObject(network)
}
