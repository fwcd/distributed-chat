//
//  Chat.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/22/21.
//

import DistributedChat

struct Chat: Identifiable {
    let name: String
    var messages: [ChatMessage]
    
    var id: String { name }
}
