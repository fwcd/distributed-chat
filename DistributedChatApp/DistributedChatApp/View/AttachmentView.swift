//
//  AttachmentView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/24/21.
//

import DistributedChat
import SwiftUI

struct AttachmentView: View {
    let attachment: ChatAttachment
    
    var body: some View {
        HStack {
            Image(systemName: "doc.fill")
            Text(attachment.name)
        }
    }
}

struct AttachmentView_Previews: PreviewProvider {
    static var previews: some View {
        AttachmentView(attachment: ChatAttachment(name: "test.txt", url: URL(string: "data:text/plain;base64,dGVzdDEyMwo=")!))
    }
}
