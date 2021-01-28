//
//  NetworkView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/23/21.
//

import DistributedChat
import SwiftUI

struct NetworkView: View {
    @EnvironmentObject private var network: Network
    
    var body: some View {
        NavigationView {
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
                                Button(action: {
                                    UIPasteboard.general.string = chatUser.id.uuidString
                                }) {
                                    Text("Copy User ID")
                                    Image(systemName: "doc.on.doc")
                                }
                                Button(action: {
                                    UIPasteboard.general.string = chatUser.name
                                }) {
                                    Text("Copy User Name")
                                    Image(systemName: "doc.on.doc")
                                }
                            }
                            Button(action: {
                                UIPasteboard.general.string = user.peripheralIdentifier.uuidString
                            }) {
                                Text("Copy Peripheral ID")
                                Image(systemName: "doc.on.doc")
                            }
                            if let peripheralName = user.peripheralName {
                                Button(action: {
                                    UIPasteboard.general.string = peripheralName
                                }) {
                                    Text("Copy Peripheral Name")
                                    Image(systemName: "doc.on.doc")
                                }
                            }
                            if let rssi = user.rssi {
                                Button(action: {
                                    UIPasteboard.general.string = String(rssi)
                                }) {
                                    Text("Copy RSSI")
                                    Image(systemName: "doc.on.doc")
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("Presences")) {
                    List(network.presences.values.sorted { $0.user.displayName < $1.user.displayName }) { presence in
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
            }
            .navigationTitle("Network")
        }
    }
}

struct NetworkView_Previews: PreviewProvider {
    static let alice = ChatUser(name: "Alice")
    static let bob = ChatUser(name: "Bob")
    @StateObject static var network = Network(nearbyUsers: [
        NearbyUser(peripheralIdentifier: UUID(uuidString: "6b61a69b-f4b4-4321-92db-9d61653ddaf6")!, chatUser: alice, rssi: -49),
        NearbyUser(peripheralIdentifier: UUID(uuidString: "b7b7d248-9640-490d-8187-44fc9ebfa1ff")!, chatUser: bob, rssi: -55),
    ], presences: [
        ChatPresence(user: alice, status: .online),
        ChatPresence(user: bob, status: .away, info: "At the gym"),
    ])
    static var previews: some View {
        NetworkView()
            .environmentObject(network)
    }
}
