//
//  FileAttachmentView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/30/21.
//

import DistributedChatKit
import SwiftUI

struct FileAttachmentView: View {
    let attachment: ChatAttachment
    
    var body: some View {
        QuickLookAttachmentView(attachment: attachment) {
            HStack {
                Image(systemName: "doc.fill")
                Text(attachment.name)
            }
        }
    }
}

#Preview {
    AttachmentView(attachment: ChatAttachment(name: "test.txt", content: .url(URL(string: "data:text/plain;base64,dGVzdDEyMwo=")!)))
}
