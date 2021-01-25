//
//  NearbyUser.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/25/21.
//

import DistributedChat
import Foundation

struct NearbyUser: Identifiable, Hashable {
    let user: ChatUser
    let rssi: Int? // in dB
    
    var id: UUID { user.id }
}
