//
//  Profile.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/24/21.
//

import Combine
import DistributedChat

class Profile: ObservableObject {
    @Published(persistingTo: "Profile/me.json") var me: ChatUser = ChatUser()
}
