//
//  Settings.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/23/21.
//

import Combine
import DistributedChatBluetooth
import Foundation

class Settings: ObservableObject {
    @Published(persistingTo: "Settings/presentation.json") var presentation = PresentationSettings()
    @Published(persistingTo: "Settings/bluetooth.json") var bluetooth = CoreBluetoothSettings()
    
    struct PresentationSettings: Codable {
        var messageHistoryStyle: MessageHistoryStyle = .bubbles
        var showChannelPreviews: Bool = true
    }
}
