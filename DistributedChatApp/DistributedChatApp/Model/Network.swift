//
//  Network.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/23/21.
//

import DistributedChat
import Combine
import Foundation

class Network: ObservableObject {
    /// The ID of our node.
    let myId: UUID
    /// Nodes that are in immediate reach, i.e. in Bluetooth LE range.
    @Published var nearbyUsers: [NearbyUser]
    /// Nodes that are reachable via the network.
    /// TODO: Expire old presences after a certain timeout
    @Published private(set) var presences: [UUID: ChatPresence]
    var messages: Messages
    
    var offlinePresences: [UUID: ChatPresence] {
        Dictionary(uniqueKeysWithValues: messages.users
            .filter { !presences.keys.contains($0.id) }
            .map { ($0.id, ChatPresence(user: $0, status: .offline)) })
    }
    var allPresences: [ChatPresence] {
        presences.values.sorted { $0.user.displayName < $1.user.displayName }
            + offlinePresences.values.sorted { $0.user.displayName < $1.user.displayName }
    }
    
    init(myId: UUID = UUID(), nearbyUsers: [NearbyUser] = [], presences: [ChatPresence] = [], messages: Messages = Messages()) {
        self.myId = myId
        self.nearbyUsers = nearbyUsers
        self.presences = Dictionary(presences.map { ($0.user.id, $0) }, uniquingKeysWith: { k, _ in k })
        self.messages = messages
    }
    
    func register(presence: ChatPresence) {
        presences[presence.user.id] = presence
    }
}
