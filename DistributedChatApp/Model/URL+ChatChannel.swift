//
//  URL+ChatChannel.swift
//  DistributedChat
//
//  Created on 04.08.24
//

import Foundation
import DistributedChatKit

extension URL {
    init(_ channel: ChatChannel) {
        self.init(string: "distributedchat:///channel/\(channel)")!
    }
}
