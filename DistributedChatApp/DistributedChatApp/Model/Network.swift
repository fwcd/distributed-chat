//
//  Network.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/23/21.
//

import DistributedChat
import Combine

class Network: ObservableObject {
    /// Nodes that are in immediate reach, i.e. in Bluetooth LE range.
    @Published var nearbyUsers: [NearbyUser]
    /// Nodes that are reachable via the network.
    @Published var presences: [ChatPresence]
    
    // TODO: Reachable users
    
    init(nearbyUsers: [NearbyUser] = [], presences: [ChatPresence] = []) {
        self.nearbyUsers = nearbyUsers
        self.presences = presences
    }
}
