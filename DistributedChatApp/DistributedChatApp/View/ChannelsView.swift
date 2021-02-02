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
    @EnvironmentObject private var navigation: Navigation
    @EnvironmentObject private var settings: Settings
    @EnvironmentObject private var network: Network
    @State private var newChannelNames: [String] = []
    @State private var channelNameDraftSheetShown: Bool = false
    @State private var deletingChannelNames: [String?] = []
    @State private var deletionConfirmationShown: Bool = false
    
    private var allChannelNames: [String?] {
        channelNames + newChannelNames.filter { !channelNames.contains($0) }
    }
    
    var body: some View {
        NavigationView {
            List {
                let nearbyCount = network.nearbyUsers.count
                let reachableCount = network.presences.filter { $0.id != controller.me.id }.count
                HStack {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                    Text("\(reachableCount) \("user".pluralized(with: reachableCount)) reachable, \(nearbyCount) \("user".pluralized(with: nearbyCount)) nearby")
                }
                ForEach(allChannelNames, id: \.self) { channelName in
                    NavigationLink(destination: ChannelView(channelName: channelName, controller: controller), tag: channelName, selection: $navigation.activeChannelName) {
                        ChannelSnippetView(channelName: channelName)
                    }
                    .contextMenu {
                        Button(action: {
                            deletingChannelNames = [channelName]
                            deletionConfirmationShown = true
                        }) {
                            Text("Delete Locally")
                            Image(systemName: "trash")
                        }
                        if messages.unreadChannelNames.contains(channelName) {
                            Button(action: {
                                messages.markAsRead(channelName: channelName)
                            }) {
                                Text("Mark as Read")
                                Image(systemName: "circlebadge")
                            }
                        }
                        if !messages.pinnedChannelNames.contains(channelName) {
                            Button(action: {
                                messages.pin(channelName: channelName)
                            }) {
                                Text("Pin")
                                Image(systemName: "pin.fill")
                            }
                        } else if channelName != nil {
                            Button(action: {
                                messages.unpin(channelName: channelName)
                            }) {
                                Text("Unpin")
                                Image(systemName: "pin.slash.fill")
                            }
                        }
                        if let channelName = channelName {
                            Button(action: {
                                UIPasteboard.general.string = channelName
                            }) {
                                Text("Copy Channel Name")
                                Image(systemName: "doc.on.doc")
                            }
                        }
                        Button(action: {
                            UIPasteboard.general.url = URL(string: "distributedchat:///channel\(channelName.map { "/\($0)" } ?? "")")
                        }) {
                            Text("Copy Channel URL")
                            Image(systemName: "doc.on.doc.fill")
                        }
                    }
                }
                .onDelete { indexSet in
                    deletingChannelNames = indexSet.map { allChannelNames[$0] }
                    deletionConfirmationShown = true
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Channels")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        channelNameDraftSheetShown = true
                    }) {
                        Image(systemName: "square.and.pencil")
                            .resizable()
                    }
                }
            }
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        .sheet(isPresented: $channelNameDraftSheetShown) {
            NewChannelView {
                channelNameDraftSheetShown = false
                newChannelNames = [$0]
            }
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
                        newChannelNames.removeAll(where: deletingChannelNames.contains)
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
    @StateObject static var navigation = Navigation()
    @StateObject static var settings = Settings()
    @StateObject static var network = Network()
    static var previews: some View {
        ChannelsView(channelNames: [], controller: ChatController(transport: MockTransport()))
            .environmentObject(messages)
            .environmentObject(navigation)
            .environmentObject(settings)
            .environmentObject(network)
    }
}
