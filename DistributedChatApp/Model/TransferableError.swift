//
//  TransferableError.swift
//  DistributedChat
//
//  Created on 04.08.24
//

import DistributedChatKit

enum TransferableError: Error {
    case couldNotEncodeImageAttachment(ChatAttachment)
    case noAttachmentsFound
}
