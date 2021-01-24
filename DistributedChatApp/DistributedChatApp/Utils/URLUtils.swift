//
//  URLUtils.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/24/21.
//

import Foundation
import MobileCoreServices

extension URL {
    var mimeType: String {
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, pathExtension as NSString, nil),
           let mt = UTTypeCopyPreferredTagWithClass(uti.takeRetainedValue(), kUTTagClassMIMEType) {
            return mt.takeRetainedValue() as String
        }
        return "application/octet-stream"
    }
}
