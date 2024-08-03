//
//  CompactMessageView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/23/21.
//

import DistributedChatKit
import SwiftUI

struct CompactMessageView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .top) {
            if message.isEncrypted {
                Image(systemName: "lock.fill")
                Text("Encrypted")
            } else {
                Text("\(message.author.displayName):")
                    .fontWeight(.bold)
                if let content = message.content.asText {
                    Text(content)
                }
                ForEach(message.attachments ?? []) { attachment in
                    AttachmentView(attachment: attachment)
                }
            }
        }
    }
}

struct CompactMessageView_Previews: PreviewProvider {
    static var previews: some View {
        CompactMessageView(message: ChatMessage(author: ChatUser(name: "Alice"), content: "Test"))
    }
}
