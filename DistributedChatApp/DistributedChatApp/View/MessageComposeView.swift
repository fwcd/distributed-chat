//
//  MessageComposeView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/24/21.
//

import DistributedChat
import Logging
import SwiftUI

fileprivate let log = Logger(label: "MessageComposeView")

struct MessageComposeView: View {
    let channelName: String?
    let controller: ChatController
    @Binding var replyingToMessageId: UUID?
    
    @EnvironmentObject private var messages: Messages
    @State private var draft: String = ""
    @State private var draftAttachmentUrls: [URL]? = nil
    @State private var attachmentPickerShown: Bool = false
    
    private var draftAttachments: [ChatAttachment]? {
        draftAttachmentUrls?.compactMap { url in
            let mimeType = url.mimeType
            let fileName = url.lastPathComponent
            do {
                let data = try Data(contentsOf: url)
                guard let url = URL(string: "data:\(mimeType);base64,\(data.base64EncodedString())") else { return nil }
                return ChatAttachment(name: fileName, url: url)
            } catch {
                log.warning("Could not attach \(fileName): \(error)")
                return nil
            }
        }
    }
    
    var body: some View {
        VStack {
            if let id = replyingToMessageId, let message = messages[id] {
                ClosableStatusBar(onClose: {
                    replyingToMessageId = nil
                }) {
                    HStack {
                        Text("Replying to")
                        PlainMessageView(message: message)
                    }
                }
            }
            let attachmentCount = draftAttachmentUrls?.count ?? 0
            if attachmentCount > 0 {
                ClosableStatusBar(onClose: {
                    draftAttachmentUrls = nil
                }) {
                    Text("Attaching \(attachmentCount) \("file".pluralized(with: attachmentCount))")
                }
            }
            HStack {
                Button(action: { attachmentPickerShown = true }) {
                    Image(systemName: "plus")
                }
                TextField("Message #\(channelName ?? globalChannelName)...", text: $draft, onCommit: sendDraft)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: sendDraft) {
                    Text("Send")
                        .fontWeight(.bold)
                }
            }
        }
        .fileImporter(isPresented: $attachmentPickerShown, allowedContentTypes: [.data], allowsMultipleSelection: false) {
            if case let .success(urls) = $0 {
                draftAttachmentUrls = urls
            }
            attachmentPickerShown = false
        }
    }
    
    private func sendDraft() {
        if !draft.isEmpty || !(draftAttachmentUrls ?? []).isEmpty {
            let attachments = draftAttachments
            print(attachments)
            controller.send(content: draft, on: channelName, attaching: attachments, replyingTo: replyingToMessageId)
            draft = ""
            draftAttachmentUrls = nil
            replyingToMessageId = nil
        }
    }
}

struct MessageComposeView_Previews: PreviewProvider {
    static let controller = ChatController(transport: MockTransport())
    @StateObject static var messages = Messages()
    @State static var replyingToMessageId: UUID? = nil
    static var previews: some View {
        MessageComposeView(channelName: nil, controller: controller, replyingToMessageId: $replyingToMessageId)
            .environmentObject(messages)
    }
}
