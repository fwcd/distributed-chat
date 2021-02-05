//
//  ViewUtils.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/23/21.
//

import SwiftUI
import DistributedChat

/// The size of icons e.g. in the compose bar
let iconSize: CGFloat = 22

/// The displayed name of the 'global' channel, internally represented with nil
fileprivate let globalChannelName = "global"

extension Optional where Wrapped == ChatChannel {
    func rawDisplayName(with network: Network) -> String {
        switch self {
        case .room(let name)?:
            return name
        case .dm(let userIds)?:
            return userIds
                .filter { $0 != network.myId }
                .map { (network.presences[$0] ?? network.offlinePresences[$0])?.user.displayName ?? $0.uuidString }
                .joined(separator: ",")
        case nil:
            return globalChannelName
        }
    }
    
    func displayName(with network: Network) -> String {
        switch self {
        case .dm(_):
            return "@\(rawDisplayName(with: network))"
        default:
            return "#\(rawDisplayName(with: network))"
        }
    }
}

extension ChatChannel {
    func rawDisplayName(with network: Network) -> String {
        Optional.some(self).rawDisplayName(with: network)
    }
    
    func displayName(with network: Network) -> String {
        Optional.some(self).displayName(with: network)
    }
}
