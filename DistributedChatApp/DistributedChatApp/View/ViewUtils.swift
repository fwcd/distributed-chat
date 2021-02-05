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
//    func displayName(with users: Users) -> String {
    var displayName: String {
        switch self {
        case .room(let name)?:
            return name
        case .dm(let userId)?:
            return userId.uuidString // TODO: Use Users to fetch user name
        case nil:
            return globalChannelName
        }
    }
}

extension ChatChannel {
    var displayName: String {
        Optional.some(self).displayName
    }
}
