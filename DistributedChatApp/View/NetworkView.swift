//
//  NetworkView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/23/21.
//

import DistributedChatKit
import DistributedChatBluetooth
import SwiftUI

struct NetworkView: View {
    @EnvironmentObject private var network: Network
    @EnvironmentObject private var navigation: Navigation
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Nearby Users")) {
                    List(network.nearbyUsers) { user in
                        HStack {
                            Text(user.displayName)
                            Spacer()
                            if let rssi = user.rssi {
                                Image(systemName: "antenna.radiowaves.left.and.right")
                                Text("\(rssi) dB")
                            }
                        }
                        .contextMenu {
                            if let chatUser = user.chatUser {
                                Button {
                                    UIPasteboard.general.string = chatUser.id.uuidString
                                } label: {
                                    Label("Copy User ID", systemImage: "doc.on.doc")
                                }
                                Button {
                                    UIPasteboard.general.string = chatUser.name
                                } label: {
                                    Label("Copy User Name", systemImage: "doc.on.doc")
                                }
                                Button {
                                    navigation.open(channel: .dm([network.myId, chatUser.id]))
                                } label: {
                                    Label("Open DM channel", systemImage: "at")
                                }
                            }
                            Button {
                                UIPasteboard.general.string = user.peripheralIdentifier.uuidString
                            } label: {
                                Label("Copy Peripheral ID", systemImage: "doc.on.doc")
                            }
                            if let peripheralName = user.peripheralName {
                                Button {
                                    UIPasteboard.general.string = peripheralName
                                } label: {
                                    Label("Copy Peripheral Name", systemImage: "doc.on.doc")
                                }
                            }
                            if let rssi = user.rssi {
                                Button {
                                    UIPasteboard.general.string = String(rssi)
                                } label: {
                                    Label("Copy RSSI", systemImage: "doc.on.doc")
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("Presences")) {
                    List(network.allPresences) { presence in
                        PresenceView(presence: presence)
                    }
                }
            }
            .navigationTitle("Network")
        }
    }
}

#Preview {
    let alice = ChatUser(name: "Alice")
    let bob = ChatUser(name: "Bob")
    let network = Network(nearbyUsers: [
        NearbyUser(peripheralIdentifier: UUID(uuidString: "6b61a69b-f4b4-4321-92db-9d61653ddaf6")!, chatUser: alice, rssi: -49),
        NearbyUser(peripheralIdentifier: UUID(uuidString: "b7b7d248-9640-490d-8187-44fc9ebfa1ff")!, chatUser: bob, rssi: -55),
    ], presences: [
        ChatPresence(user: alice, status: .online),
        ChatPresence(user: bob, status: .away, info: "At the gym"),
    ], messages: Messages())
    let navigation = Navigation()
    
    return NetworkView()
        .environmentObject(network)
        .environmentObject(navigation)
}
