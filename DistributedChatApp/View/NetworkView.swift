//
//  NetworkView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/23/21.
//

import DistributedChatKit
import SwiftUI

struct NetworkView: View {
    @EnvironmentObject private var network: Network
    @EnvironmentObject private var navigation: Navigation
    
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
                                Button(action: {
                                    navigation.open(channel: .dm([network.myId, chatUser.id]))
                                }) {
                                    Text("Open DM channel")
                                    Image(systemName: "at")
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
                    List(network.allPresences) { presence in
                        PresenceView(presence: presence)
                    }
                }
            }
            .navigationTitle("Network")
        }
        .navigationViewStyle(StackNavigationViewStyle())
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
    ], messages: Messages())
    @StateObject static var navigation = Navigation()
    
    static var previews: some View {
        NetworkView()
            .environmentObject(network)
            .environmentObject(navigation)
    }
}
