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
    /// Nodes that are in immediate reach, i.e. in Bluetooth LE range.
    @Published var nearbyUsers: [NearbyUser]
    /// Nodes that are reachable via the network.
    /// TODO: Expire old presences after a certain timeout
    @Published private(set) var presences: [UUID: ChatPresence]
    
    // TODO: Reachable users
    
    init(nearbyUsers: [NearbyUser] = [], presences: [ChatPresence] = []) {
        self.nearbyUsers = nearbyUsers
        self.presences = Dictionary(presences.map { ($0.user.id, $0) }, uniquingKeysWith: { k, _ in k })
    }
    
    func register(presence: ChatPresence) {
        presences[presence.user.id] = presence
    }
}
