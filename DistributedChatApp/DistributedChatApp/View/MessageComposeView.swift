//
//  MessageComposeView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/24/21.
//

import DistributedChat
import Logging
import SwiftUI

fileprivate let log = Logger(label: "DistributedChatApp.MessageComposeView")

struct MessageComposeView: View {
    let channelName: String?
    let controller: ChatController
    @Binding var replyingToMessageId: UUID?
    
    @EnvironmentObject private var messages: Messages
    @State private var draft: String = ""
    @State private var draftFileUrls: [URL] = []
    @State private var draftImageUrls: [URL] = []
    @State private var draftVoiceNoteUrl: URL? = nil
    @State private var attachmentActionSheetShown: Bool = false
    @State private var attachmentFilePickerShown: Bool = false
    @State private var attachmentImagePickerShown: Bool = false
    @State private var attachmentImagePickerStyle: ImagePicker.SourceType = .photoLibrary
    
    private var draftAttachmentUrls: [(URL, ChatAttachmentType)] {
        [
            draftFileUrls.map { ($0, .file) },
            draftImageUrls.map { ($0, .image) },
            [(draftVoiceNoteUrl, .voiceNote)]
        ]
        .joined()
        .compactMap { (opt, type) in opt.map { ($0, type) } }
    }
    
    private var draftAttachments: [ChatAttachment] {
        draftAttachmentUrls.compactMap { (url, type) in
            let mimeType = url.mimeType
            let fileName = url.lastPathComponent
            print(url)
            guard let data = try? Data.smartContents(of: url),
                  let url = URL(string: "data:\(mimeType);base64,\(data.base64EncodedString())") else { return nil }
            return ChatAttachment(type: type, name: fileName, url: url)
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
            let attachmentCount = draftAttachmentUrls.count
            if attachmentCount > 0 {
                ClosableStatusBar(onClose: {
                    clearAttachments()
                }) {
                    Text("\(attachmentCount) \("attachment".pluralized(with: attachmentCount))")
                }
            }
            HStack {
                Button(action: { attachmentActionSheetShown = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: iconSize))
                }
                TextField("Message #\(channelName ?? globalChannelName)...", text: $draft, onCommit: sendDraft)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                if draft.isEmpty && draftAttachmentUrls.isEmpty {
                    VoiceNoteRecordButton {
                        draftVoiceNoteUrl = $0
                    }
                    .font(.system(size: iconSize))
                } else {
                    Button(action: sendDraft) {
                        Text("Send")
                            .fontWeight(.bold)
                    }
                }
            }
        }
        .actionSheet(isPresented: $attachmentActionSheetShown) {
            ActionSheet(
                title: Text("Add Attachment"),
                buttons: [
                    .default(Text("Photo Library")) {
                        attachmentImagePickerStyle = .photoLibrary
                        attachmentImagePickerShown = true
                    },
                    .default(Text("Camera")) {
                        attachmentImagePickerStyle = .camera
                        attachmentImagePickerShown = true
                    },
                    .default(Text("File")) {
                        attachmentFilePickerShown = true
                    },
                    .cancel {
                        // TODO: Workaround for attachmentFilePickerShown
                        // staying true if the user only slides the sheet
                        // down.
                        attachmentFilePickerShown = false
                    },
                ]
            )
        }
        .sheet(isPresented: $attachmentImagePickerShown) {
            ImagePicker(sourceType: attachmentImagePickerStyle) {
                draftImageUrls = [$0].compactMap { $0 }
                attachmentImagePickerShown = false
            }
        }
        .fileImporter(isPresented: $attachmentFilePickerShown, allowedContentTypes: [.data], allowsMultipleSelection: false) {
            if case let .success(urls) = $0 {
                draftFileUrls = urls
            }
            attachmentFilePickerShown = false
        }
    }
    
    private func sendDraft() {
        if !draft.isEmpty || !draftAttachmentUrls.isEmpty {
            let attachments = draftAttachments.nilIfEmpty
            controller.send(content: draft, on: channelName, attaching: attachments, replyingTo: replyingToMessageId)
            clearDraft()
        }
    }
    
    private func clearDraft() {
        clearAttachments()
        draft = ""
        replyingToMessageId = nil
    }
    
    private func clearAttachments() {
        draftImageUrls = []
        draftFileUrls = []
        draftVoiceNoteUrl = nil
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
