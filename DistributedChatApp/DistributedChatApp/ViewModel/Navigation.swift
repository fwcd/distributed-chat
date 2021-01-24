//
//  Navigation.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/25/21.
//

import Combine

class Navigation: ObservableObject {
    @Published var activeChannelName: String?? = nil
}
