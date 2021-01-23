//
//  DistributedChatAppApp.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/17/21.
//

import DistributedChat
import SwiftUI

private class AppState {
    let settings: Settings
    let nearby: Nearby
    let transport: ChatTransport
    let controller: ChatController
    let messages: Messages
    
    init() {
        let settings = Settings()
        let nearby = Nearby()
        let transport = CoreBluetoothTransport(settings: settings, nearby: nearby)
        let controller = ChatController(transport: transport)
        let messages = Messages()
        
        controller.onAddChatMessage { [unowned messages] message in
            messages.append(message: message)
        }
        
        self.settings = settings
        self.nearby = nearby
        self.transport = transport
        self.controller = controller
        self.messages = messages
    }
}

private let state = AppState()

@main
struct DistributedChatApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(controller: state.controller)
                .environmentObject(state.settings)
                .environmentObject(state.messages)
                .environmentObject(state.nearby)
        }
    }
    
    init() {
        UIScrollView.appearance().keyboardDismissMode = .interactive
    }
}
