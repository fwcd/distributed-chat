//
//  DistributedChatAppApp.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/17/21.
//

import Combine
import DistributedChat
import Logging
import LoggingOSLog
import SwiftUI

private class AppState {
    let settings: Settings
    let nearby: Nearby
    let profile: Profile
    let transport: ChatTransport
    let controller: ChatController
    let messages: Messages
    
    private var subscriptions: [AnyCancellable] = []
    
    init() {
        LoggingSystem.bootstrap(LoggingOSLog.init)
        
        let settings = Settings()
        let nearby = Nearby()
        let profile = Profile()
        let transport = CoreBluetoothTransport(settings: settings, nearby: nearby)
        let controller = ChatController(transport: transport)
        let messages = Messages()
        
        controller.onAddChatMessage { [unowned messages] message in
            messages.append(message: message)
        }
        
        controller.update(me: profile.me)
        subscriptions.append(profile.$me.sink(receiveValue: controller.update(me:)))
        
        self.settings = settings
        self.nearby = nearby
        self.profile = profile
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
                .environmentObject(state.profile)
        }
    }
    
    init() {
        UIScrollView.appearance().keyboardDismissMode = .interactive
    }
}
