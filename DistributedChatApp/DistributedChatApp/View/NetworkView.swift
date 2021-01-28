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
            }
            .navigationTitle("Network")
        }
    }
}

struct NetworkView_Previews: PreviewProvider {
    @StateObject static var network = Network(nearbyUsers: [
        NearbyUser(peripheralIdentifier: UUID(uuidString: "6b61a69b-f4b4-4321-92db-9d61653ddaf6")!, chatUser: ChatUser(name: "Alice"), rssi: -49),
        NearbyUser(peripheralIdentifier: UUID(uuidString: "b7b7d248-9640-490d-8187-44fc9ebfa1ff")!, chatUser: ChatUser(name: "Bob"), rssi: -55)
    ])
    static var previews: some View {
        NetworkView()
            .environmentObject(network)
    }
}
