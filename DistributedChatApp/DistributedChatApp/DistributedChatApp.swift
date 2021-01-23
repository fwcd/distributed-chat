//
//  DistributedChatAppApp.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/17/21.
//

import DistributedChat
import SwiftUI

private let settings = Settings()
private let transport = CoreBluetoothTransport(settings: settings)
private let controller = ChatController(transport: transport)

@main
struct DistributedChatApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(controller: controller)
                .environmentObject(settings)
        }
    }
    
    init() {
        UIScrollView.appearance().keyboardDismissMode = .interactive
    }
}
