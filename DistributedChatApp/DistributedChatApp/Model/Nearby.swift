//
//  Nearby.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/23/21.
//

import DistributedChat
import Combine

class Nearby: ObservableObject {
    /// Nodes that are in immediate reach, i.e. in Bluetooth LE range.
    @Published var nearbyUsers: [NearbyUser] = []
    
    // TODO: Reachable users
}
