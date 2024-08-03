//
//  ChatAttachment+Transferable.swift
//  DistributedChat
//
//  Created on 04.08.24
//

import CoreTransferable
import DistributedChatKit
import SwiftUI

extension ChatAttachment: Transferable {
    public static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation { attachment in
            guard let data = try? attachment.extractedData(),
                  let uiImage = UIImage(data: data) else { throw TransferableError.couldNotEncodeImageAttachment(attachment) }
            return Image(uiImage: uiImage)
        }
        .exportingCondition { attachment in
            attachment.type == .image
        }
        
        // TODO: Add other types of attachments and their representations
    }
}
