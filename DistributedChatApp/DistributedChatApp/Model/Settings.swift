//
//  Settings.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/23/21.
//

import Combine

class Settings: ObservableObject {
    @Published var messageHistoryStyle: MessageHistoryStyle = .bubbles
    @Published var showChannelPreviews: Bool = true
    @Published var bluetoothAdvertisingEnabled: Bool = true
    @Published var bluetoothScanningEnabled: Bool = true
}
