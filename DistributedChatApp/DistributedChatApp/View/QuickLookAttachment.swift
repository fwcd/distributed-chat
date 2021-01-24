//
//  QuickLookAttachment.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/24/21.
//

import DistributedChat
import Foundation
import Logging
import QuickLook

fileprivate let log = Logger(label: "QuickLookAttachment")

class QuickLookAttachment: NSObject, QLPreviewItem {
    private let attachment: ChatAttachment
    private let tempURL: URL
    
    var previewItemURL: URL? { tempURL }
    var previewItemTitle: String? { attachment.name }
    
    init(attachment: ChatAttachment) throws {
        self.attachment = attachment
        tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(attachment.name)
        try Data(contentsOf: attachment.url).write(to: tempURL) // might overwrite an old file with that attachment name
    }
    
    deinit {
        log.info("Cleaning up temporary file from attachment...")
        try? FileManager.default.removeItem(at: tempURL)
    }
}