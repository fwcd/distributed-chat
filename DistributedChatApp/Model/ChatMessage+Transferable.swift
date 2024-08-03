//
//  ChatMessage+Transferable.swift
//  DistributedChat
//
//  Created on 04.08.24
//

import CoreTransferable
import DistributedChatKit

extension ChatMessage: Transferable {
    public static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .chatMessage, encoder: makeJSONEncoder(), decoder: makeJSONDecoder())
        ProxyRepresentation(exporting: \.displayContent)
            .exportingCondition { !$0.displayContent.isEmpty }
        ProxyRepresentation { message in
            guard let attachment = message.attachments?.first else {
                throw TransferableError.noAttachmentsFound
            }
            return attachment
        }
        .exportingCondition { !($0.attachments?.isEmpty ?? true) }
    }
}
