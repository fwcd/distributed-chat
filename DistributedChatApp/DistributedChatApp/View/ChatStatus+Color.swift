//
//  ChatStatus+Color.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/28/21.
//

import DistributedChat
import SwiftUI

extension ChatStatus {
    var color: Color {
        switch self {
        case .online:
            return .green
        case .away:
            return .yellow
        case .busy:
            return .red
        }
    }
}
