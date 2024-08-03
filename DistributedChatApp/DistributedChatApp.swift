//
//  DistributedChatAppApp.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/17/21.
//

import AVFoundation
import Combine
import DistributedChatKit
import DistributedChatBluetooth
import Dispatch
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
        let profile = Profile()
        let navigation = Navigation()
        let messages = Messages()
        let network = Network(myId: profile.me.id, messages: messages)
        let transport = CoreBluetoothTransport(
            settings: settings.$bluetooth.eraseToAnyPublisher(),
            me: profile.$presence.map(\.user).eraseToAnyPublisher(),
            onUpdateNearbyUsers: { users in
                network.nearbyUsers = users
            }
        )
        let controller = ChatController(me: profile.me, transport: transport)
        
        controller.onAddChatMessage { [unowned messages] message in
            DispatchQueue.main.async {
                messages.append(message: message)
            }
        }
        
        controller.onUpdatePresence { [unowned network] presence in
            DispatchQueue.main.async {
                network.register(presence: presence)
            }
        }
        
        controller.onFindUser { [unowned network] id in
            network.presences[id]?.user ?? network.offlinePresences[id]?.user
        }
        
        subscriptions.append(profile.$presence.sink(receiveValue: controller.update(presence:)))
        
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
                                    content.title = "\(message.author.displayName) in \(message.channel.displayName(with: state.network))"
                                    content.body = message.displayContent
                                    content.targetContentIdentifier = "distributedchat:///message/\(message.id)"
                                    content.sound = UNNotificationSound.default       
                                    let request = UNNotificationRequest(identifier: "DistributedChat message", content: content, trigger: nil)
                                    center.add(request) { error in
                                        if let error = error {
                                            log.error("Error while delivering notification: \(error)")
                                        }
                                    }
                                }
                                state.subscriptions.append(state.messages.$unreadMessageIds.sink { unread in
                                    Task {
                                        try await UNUserNotificationCenter.current().setBadgeCount(unread.count)
                                    }
                                })
                                log.info("Registered notification handler!")
                            }
                        }
                    }
                }
                .onAppear {
                    do {
                        let session = AVAudioSession.sharedInstance()
                        try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
                    } catch {
                        log.warning("Could not configure audio session: \(error)")
                    }
                }
                .onOpenURL { url in
                    guard url.isDistributedChatSchemed else { return }
                    
                    // distributedchat:///channel           --> channel #global
                    // distributedchat:///channel/room:test --> channel #test
                    // distributedchat:///message/<uuid>    --> specific message (TODO: Actually scroll to message)
                    
                    log.info("Opening URL \(url)...")
                    
                    let components = url.pathComponents
                    if components.count >= 2 {
                        switch components[..<2] {
                        case ["/", "channel"]:
                            if components.count == 3 {
                                let rawChannel = components[2]
                                do {
                                    let channel = try ChatChannel(parsing: rawChannel)
                                    if state.messages.channels.contains(channel) {
                                        log.debug("Parsed URL as \(channel.displayName(with: state.network))...")
                                        state.navigation.open(channel: channel)
                                    }
                                } catch {
                                    log.warning("Could not parse channel URL: \(error)")
                                }
                            } else {
                                log.debug("Parsed URL as #global...")
                                state.navigation.open(channel: nil)
                            }
                        case ["/", "message"]:
                            if components.count == 3, let id = UUID(uuidString: components[2]), let message = state.messages[id] {
                                log.debug("Parsed URL as message with ID \(id)...")
                                state.navigation.activeChannel = message.channel
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
