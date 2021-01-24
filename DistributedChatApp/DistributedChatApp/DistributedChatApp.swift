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
import UserNotifications
import SwiftUI

private class AppState {
    let settings: Settings
    let nearby: Nearby
    let profile: Profile
    let transport: ChatTransport
    let controller: ChatController
    let messages: Messages
    
    var subscriptions: [AnyCancellable] = []
    
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
private let log = Logger(label: "DistributedChatApp.DistributedChatApp")

@main
struct DistributedChatApp: App {
    @State private var notificationsInitialized: Bool = false
    
    var body: some Scene {
        WindowGroup {
            ContentView(controller: state.controller)
                .environmentObject(state.settings)
                .environmentObject(state.messages)
                .environmentObject(state.nearby)
                .environmentObject(state.profile)
                .onAppear {
                    if !notificationsInitialized {
                        notificationsInitialized = true
                        let center = UNUserNotificationCenter.current()
                        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                            if let error = error {
                                log.error("Error while requesting notifications permission: \(error)")
                            }
                            if granted {
                                state.controller.onAddChatMessage { message in
                                    let content = UNMutableNotificationContent()
                                    content.title = "\(message.author.displayName) in #\(message.channelName ?? globalChannelName)"
                                    content.body = message.content
                                    let request = UNNotificationRequest(identifier: "DistributedChat message", content: content, trigger: nil)
                                    center.add(request) { error in
                                        if let error = error {
                                            log.error("Error while delivering notification: \(error)")
                                        }
                                    }
                                }
                                state.subscriptions.append(state.messages.$unread.sink { unread in
                                    DispatchQueue.main.async {
                                        UIApplication.shared.applicationIconBadgeNumber = unread.count
                                    }
                                })
                                log.info("Registered notification handler!")
                            }
                        }
                    }
                }
        }
    }
    
    init() {
        UIScrollView.appearance().keyboardDismissMode = .interactive
    }
}
