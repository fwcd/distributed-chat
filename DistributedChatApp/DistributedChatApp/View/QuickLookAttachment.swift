//
//  QuickLookAttachment.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/24/21.
//

import DistributedChat
import Foundation
import QuickLook

class QuickLookAttachment: NSObject, QLPreviewItem {
    private let attachment: ChatAttachment
    
    var previewItemURL: URL? { attachment.url }
    var previewItemTitle: String? { attachment.name }
    
    init(attachment: ChatAttachment) {
        self.attachment = attachment
    }
}
