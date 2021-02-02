//
//  MessageComposeView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/24/21.
//

import DistributedChat
import Contacts
import Logging
import SwiftUI
import SwiftUIKit

fileprivate let log = Logger(label: "DistributedChatApp.MessageComposeView")

struct MessageComposeView: View {
    let channelName: String?
    let controller: ChatController
    @Binding var replyingToMessageId: UUID?
    
    @EnvironmentObject private var messages: Messages
    @State private var draft: String = ""
    @State private var draftAttachments: [DraftAttachment] = []
    @State private var attachmentActionSheetShown: Bool = false
    @State private var attachmentFilePickerShown: Bool = false
    @State private var attachmentContactPickerShown: Bool = false
    @State private var attachmentImagePickerShown: Bool = false
    @State private var attachmentImagePickerStyle: ImagePicker.SourceType = .photoLibrary
    
    private enum DraftAttachment {
        case file(URL)
        case image(URL)
        case voiceNote(URL)
        case contact(CNContact)
        
        var asURL: URL? {
            switch self {
            case .file(let url):
                return url
            case .image(let url):
                return url
            case .voiceNote(let url):
                return url
            default:
                return nil
            }
        }
        var asChatAttachmentType: ChatAttachmentType {
            switch self {
            case .file(_):
                return .file
            case .image(_):
                return .image
            case .voiceNote(_):
                return .voiceNote
            case .contact(_):
                return .contact
            }
        }
        var asChatAttachment: ChatAttachment? {
            guard let url = asURL else { return nil }
            let mimeType = url.mimeType
            let fileName = url.lastPathComponent
            guard let data = try? Data.smartContents(of: url),
                  let dataURL = URL(string: "data:\(mimeType);base64,\(data.base64EncodedString())") else { return nil }
            return ChatAttachment(
                type: asChatAttachmentType,
                name: fileName,
                url: dataURL
            )
        }
    }
    
    var body: some View {
        ZStack {
            // Dummy view for presenting the contacts UI, see SwiftUIKit
            ContactPicker(showPicker: $attachmentContactPickerShown) {
                draftAttachments.append(.contact($0))
            }
            .frame(width: 0, height: 0, alignment: .center)
            
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
                let attachmentCount = draftAttachments.count
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
                    if draft.isEmpty && draftAttachments.isEmpty {
                        VoiceNoteRecordButton {
                            draftAttachments.append(.voiceNote($0))
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
                        .default(Text("Contact")) {
                            attachmentContactPickerShown = true
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
            .fullScreenCover(isPresented: $attachmentImagePickerShown) {
                ImagePicker(sourceType: attachmentImagePickerStyle) {
                    if let url = $0 {
                        draftAttachments.append(.image(url))
                    }
                    attachmentImagePickerShown = false
                }.edgesIgnoringSafeArea(.all)
            }
            .fileImporter(isPresented: $attachmentFilePickerShown, allowedContentTypes: [.data], allowsMultipleSelection: false) {
                if case let .success(urls) = $0 {
                    draftAttachments += urls.map { .file($0) }
                }
                attachmentFilePickerShown = false
            }
        }
    }
    
    private func sendDraft() {
        if !draft.isEmpty || !draftAttachments.isEmpty {
            let attachments = draftAttachments.compactMap(\.asChatAttachment).nilIfEmpty
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
        draftAttachments = []
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
