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

private class AppState {
    let settings: Settings
    let network: Network
    let profile: Profile
    let navigation: Navigation
    let transport: ChatTransport
    let controller: ChatController
    let messages: Messages
    
    var subscriptions: [AnyCancellable] = []
    
    init() {
        LoggingSystem.bootstrap(LoggingOSLog.init)
        
        let settings = Settings()
        let network = Network()
        let profile = Profile()
        let navigation = Navigation()
        let transport = CoreBluetoothTransport(settings: settings, network: network, profile: profile)
        let controller = ChatController(transport: transport)
        let messages = Messages()
        
        controller.onAddChatMessage { [unowned messages] message in
            messages.append(message: message)
        }
        
        subscriptions.append(profile.$me.sink(receiveValue: controller.update(me:)))
        
        self.settings = settings
        self.network = network
        self.profile = profile
        self.navigation = navigation
        self.transport = transport
        self.controller = controller
        self.messages = messages
    }
}

private class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        log.info("Opening from notification...")
        if let target = response.notification.request.content.targetContentIdentifier, let url = URL(string: target) {
            log.info("Found URL \(url), opening it...")
            UIApplication.shared.open(url)
        }
        completionHandler()
    }
}

private let state = AppState()
private let notificationDelegate = NotificationDelegate()
private let log = Logger(label: "DistributedChatApp.DistributedChatApp")

@main
struct DistributedChatApp: App {
    @State private var notificationsInitialized: Bool = false
    
    var body: some Scene {
        WindowGroup {
            ContentView(controller: state.controller)
                .environmentObject(state.settings)
                .environmentObject(state.messages)
                .environmentObject(state.navigation)
                .environmentObject(state.network)
                .environmentObject(state.profile)
                .onAppear {
                    if !notificationsInitialized {
                        notificationsInitialized = true
                        let center = UNUserNotificationCenter.current()
                        center.delegate = notificationDelegate
                        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                            if let error = error {
                                log.error("Error while requesting notifications permission: \(error)")
                            }
                            if granted {
                                state.controller.onAddChatMessage { message in
                                    let content = UNMutableNotificationContent()
                                    content.title = "\(message.author.displayName) in #\(message.channelName ?? globalChannelName)"
                                    content.body = message.content
                                    content.targetContentIdentifier = "distributedchat:///message/\(message.id)"
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
                .onOpenURL { url in
                    // distributedchat:///channel           --> channel #global
                    // distributedchat:///channel/test      --> channel #test
                    // distributedchat:///message/<uuid>    --> specific message (TODO: Actually scroll to message)
                    
                    log.info("Opening URL \(url)...")
                    
                    let components = url.pathComponents
                    if components.count >= 2 {
                        switch components[..<2] {
                        case ["/", "channel"]:
                            if components.count == 3 {
                                let channelName = components[2]
                                if state.messages.channelNames.contains(channelName) {
                                    log.debug("Parsed URL as #\(channelName)...")
                                    state.navigation.activeChannelName = channelName
                                }
                            } else {
                                log.debug("Parsed URL as #global...")
                                state.navigation.activeChannelName = Optional<String?>.some(nil)
                            }
                        case ["/", "message"]:
                            if components.count == 3, let id = UUID(uuidString: components[2]), let message = state.messages[id] {
                                log.debug("Parsed URL as message with ID \(id)...")
                                state.navigation.activeChannelName = message.channelName
                            }
                        default:
                            break
                        }
                    }
                }
        }
    }
    
    init() {
        UIScrollView.appearance().keyboardDismissMode = .interactive
    }
}
