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
import UserNotifications

#if os(iOS)
import UIKit
#endif

private class AppState {
    let settings: Settings
    let nearby: Nearby
    let profile: Profile
    let navigation: Navigation
    let transport: ChatTransport
    let controller: ChatController
    let messages: Messages
    
    var subscriptions: [AnyCancellable] = []
    
    init() {
        LoggingSystem.bootstrap(LoggingOSLog.init)
        
        let settings = Settings()
        let nearby = Nearby()
        let profile = Profile()
        let navigation = Navigation()
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
        self.navigation = navigation
        self.transport = transport
        self.controller = controller
        self.messages = messages
    }
}

private let state = AppState()
private let log = Logger(label: "DistributedChatApp.DistributedChatApp")

#if os(iOS)
private class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        // distributedchat:///channel           --> channel #global
        // distributedchat:///channel/test      --> channel #test
        // distributedchat:///message/<uuid>    --> specific message (TODO: Actually scroll to message)
        
        log.info("Handling URL \(url)...")
        let components = url.pathComponents
        if components.count >= 2 {
            switch components[..<2] {
            case ["/", "channel"]:
                if components.count == 3 {
                    let channelName = components[2]
                    if state.messages.channelNames.contains(channelName) {
                        log.info("Opening URL \(url) as #\(channelName)...")
                        state.navigation.activeChannelName = channelName
                        return true
                    }
                } else {
                    log.info("Opening URL \(url) as #global...")
                    state.navigation.activeChannelName = Optional<String?>.some(nil)
                    return true
                }
            case ["/", "message"]:
                if components.count == 3, let id = UUID(uuidString: components[2]), let message = state.messages[id] {
                    log.info("Opening URL \(url) as message with ID \(id)...")
                    state.navigation.activeChannelName = message.channelName
                    return true
                }
            default:
                break
            }
        }
        return false
    }
}
#endif

@main
struct DistributedChatApp: App {
    #if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    #endif
    
    @State private var notificationsInitialized: Bool = false
    
    var body: some Scene {
        WindowGroup {
            ContentView(controller: state.controller)
                .environmentObject(state.settings)
                .environmentObject(state.messages)
                .environmentObject(state.navigation)
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
