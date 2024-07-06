//
//  URLUtils.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/24/21.
//

import Foundation
import UniformTypeIdentifiers

extension URL {
    var mimeType: String {
        UTType(filenameExtension: pathExtension)?.preferredMIMEType ?? "application/octet-stream"
    }
    
    var isDistributedChatSchemed: Bool {
        scheme == "distributedchat"
    }
    var distributedChatAttachmentURL: URL? {
        // distributedchat:///attachment/a/b.txt refers to <Documents>/Attachments/a/b.txt
        
        if isDistributedChatSchemed && pathComponents[..<2] == ["/", "attachment"] {
            return persistenceFileURL(path: "Attachments/\(pathComponents[2...].joined(separator: "/"))")
        } else {
            return nil
        }
    }
    var smartResolved: URL {
        distributedChatAttachmentURL ?? self
    }
    
    func smartCheckResourceIsReachable() throws -> Bool {
        try smartResolved.checkResourceIsReachable()
    }
}
