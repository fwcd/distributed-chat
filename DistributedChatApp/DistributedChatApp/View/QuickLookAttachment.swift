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
    private let tempURL: URL?
    
    var previewItemURL: URL? { tempURL ?? attachment.url }
    var previewItemTitle: String? { attachment.name }
    
    init(attachment: ChatAttachment, useTempFile: Bool = false) throws {
        self.attachment = attachment
        
        if useTempFile {
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(attachment.name)
            try Data(contentsOf: attachment.url).write(to: url) // might overwrite an old file with that attachment name
            tempURL = url
        } else {
            tempURL = nil
        }
    }
    
    deinit {
        if let url = tempURL {
            log.info("Cleaning up temporary file from attachment...")
            try? FileManager.default.removeItem(at: url)
        }
    }
}
