//
//  ChatChannel+Transferable.swift
//  DistributedChat
//
//  Created on 04.08.24
//

import CoreTransferable
import DistributedChatKit

extension ChatChannel: Transferable {
    public static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: URL.init(_:))
    }
}
