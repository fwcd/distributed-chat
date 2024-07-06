//
//  Navigation.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/25/21.
//

import Combine
import DistributedChat

class Navigation: ObservableObject {
    @Published var activeChannel: ChatChannel?? = nil
    
    func open(channel: ChatChannel?) {
        activeChannel = Optional.some(channel)
    }
}
