//
//  Channel.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/22/21.
//

import DistributedChatKit

struct Channel: Identifiable {
    let name: String?
    var messages: [ChatMessage]
    
    var displayName: String { name ?? "global" }
    var id: String { displayName }
}
