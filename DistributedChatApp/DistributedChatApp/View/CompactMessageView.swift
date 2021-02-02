//
//  CompactMessageView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/23/21.
//

import DistributedChat
import SwiftUI

struct CompactMessageView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .top) {
            Text("\(message.author.displayName):")
                .fontWeight(.bold)
            Text(message.content)
            ForEach(message.attachments ?? []) { attachment in
                AttachmentView(attachment: attachment)
            }
        }
    }
}

struct CompactMessageView_Previews: PreviewProvider {
    static var previews: some View {
        CompactMessageView(message: ChatMessage(author: ChatUser(name: "Alice"), content: "Test"))
    }
}
