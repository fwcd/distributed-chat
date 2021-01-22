//
//  DistributedChatAppApp.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/17/21.
//

import DistributedChat
import SwiftUI

@main
struct DistributedChatApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(controller: ChatController(transport: CoreBluetoothTransport()))
        }
    }
}
