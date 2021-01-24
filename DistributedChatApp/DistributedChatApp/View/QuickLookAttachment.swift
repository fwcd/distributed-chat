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
    private let tempURL: URL
    
    var previewItemURL: URL? { tempURL }
    var previewItemTitle: String? { attachment.name }
    
    init(attachment: ChatAttachment) throws {
        self.attachment = attachment
        let docDir = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let tmpDir = docDir.appendingPathComponent("tmp")
        try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
        tempURL = tmpDir.appendingPathComponent(attachment.name)
        try Data(contentsOf: attachment.url).write(to: tempURL) // might overwrite an old file with that attachment name
    }
    
    deinit {
        try? FileManager.default.removeItem(at: tempURL)
    }
}
