//
//  ImageAttachmentView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 2/2/21.
//

import DistributedChat
import SwiftUI

struct ImageAttachmentView: View {
    let attachment: ChatAttachment
    
    var body: some View {
        QuickLookAttachmentView(attachment: attachment) {
            if let data = try? attachment.extractedData(), let image = UIImage(data: data) {
                Group {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)
                }
                .frame(width: 160)
            } else {
                // Fall back to a FileAttachmentView-style label
                HStack {
                    Image(systemName: "photo")
                    Text(attachment.name)
                }
            }
        }
    }
}
