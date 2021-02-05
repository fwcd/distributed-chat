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
            if userIds.count == 1, let userId = userIds.first {
                return name(of: userId, with: network)
            } else {
                return userIds
                    .filter { $0 != network.myId }
                    .map { name(of: $0, with: network) }
                    .joined(separator: ",")
            }
        case nil:
            return globalChannelName
        }
    }
    
    private func name(of userId: UUID, with network: Network) -> String {
        (network.presences[userId] ?? network.offlinePresences[userId])?.user.displayName ?? userId.uuidString
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
