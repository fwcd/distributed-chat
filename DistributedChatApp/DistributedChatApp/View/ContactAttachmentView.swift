//
//  ContactAttachmentView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 2/2/21.
//

import DistributedChat
import SwiftUI

struct ContactAttachmentView: View {
    let attachment: ChatAttachment
    
    var body: some View {
        QuickLookAttachmentView(attachment: attachment) {
            HStack {
                Image(systemName: "person.fill")
                Text(attachment.name)
            }
        }
    }
}
