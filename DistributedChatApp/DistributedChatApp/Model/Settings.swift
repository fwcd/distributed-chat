//
//  Settings.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/23/21.
//

import Combine

class Settings: ObservableObject {
    @Published var messageHistoryStyle: MessageHistoryStyle = .compact
    @Published var showChannelPreviews: Bool = true
}
