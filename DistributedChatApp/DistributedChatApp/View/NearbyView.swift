//
//  NearbyView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/23/21.
//

import DistributedChat
import SwiftUI

struct NearbyView: View {
    @EnvironmentObject private var nearby: Nearby
    
    var body: some View {
        NavigationView {
            List(nearby.nearbyUsers) { user in
                HStack {
                    Text(user.user.displayName)
                    Spacer()
                    if let rssi = user.rssi {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                        Text("\(rssi) dB")
                    }
                }
                .contextMenu {
                    Button(action: {
                        UIPasteboard.general.string = user.id.uuidString
                    }) {
                        Text("Copy User ID")
                        Image(systemName: "doc.on.doc")
                    }
                    Button(action: {
                        UIPasteboard.general.string = user.user.name
                    }) {
                        Text("Copy User Name")
                        Image(systemName: "doc.on.doc")
                    }
                }
            }
            .navigationTitle("Nearby")
        }
    }
}

struct NearbyView_Previews: PreviewProvider {
    @StateObject static var nearby = Nearby(nearbyUsers: [
        NearbyUser(user: ChatUser(name: "Alice"), rssi: -49),
        NearbyUser(user: ChatUser(name: "Bob"), rssi: -55)
    ])
    static var previews: some View {
        NearbyView()
            .environmentObject(nearby)
    }
}
