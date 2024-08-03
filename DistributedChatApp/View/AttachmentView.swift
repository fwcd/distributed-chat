//
//  AttachmentView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/24/21.
//

import DistributedChatKit
import SwiftUI

struct AttachmentView: View {
    let attachment: ChatAttachment
    var voiceNoteColor: Color = .primary
    
    var body: some View {
        switch attachment.type {
        case .voiceNote:
            VoiceNoteAttachmentView(attachment: attachment, color: voiceNoteColor)
        case .image:
            ImageAttachmentView(attachment: attachment)
        case .contact:
            ContactAttachmentView(attachment: attachment)
        default:
            FileAttachmentView(attachment: attachment)
        }
    }
}

struct AttachmentView_Previews: PreviewProvider {
    static var previews: some View {
        AttachmentView(attachment: ChatAttachment(name: "test.txt", content: .url(URL(string: "data:text/plain;base64,dGVzdDEyMwo=")!)))
    }
}
