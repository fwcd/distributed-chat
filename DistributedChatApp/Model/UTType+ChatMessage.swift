//
//  UTType+ChatMessage.swift
//  DistributedChat
//
//  Created on 04.08.24
//

import UniformTypeIdentifiers

extension UTType {
    static var chatMessage: UTType {
        UTType(exportedAs: "dev.fwcd.DistributedChat.ChatMessage")
    }
}
