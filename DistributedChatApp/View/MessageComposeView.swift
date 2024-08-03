//
//  MessageComposeView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/24/21.
//

import DistributedChatKit
import Contacts
import Logging
import SwiftUI

fileprivate let log = Logger(label: "DistributedChatApp.MessageComposeView")

/// The compression algorithm used for encoding.
fileprivate let compression: ChatAttachment.Compression = .lzfse

struct MessageComposeView: View {
    let channel: ChatChannel
    let controller: ChatController
    @Binding var replyingToMessageId: UUID?
    
    @EnvironmentObject private var messages: Messages
    @EnvironmentObject private var network: Network
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
        
        var url: URL? {
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
        var type: ChatAttachmentType {
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
        var mimeType: String {
            url?.mimeType ?? "application/octet-stream"
        }
        var fileName: String {
            if let url = url {
                return url.lastPathComponent
            } else if case .contact(let contact) = self {
                let name = [
                    contact.namePrefix,
                    contact.givenName,
                    contact.familyName,
                    contact.nameSuffix
                ].compactMap(\.nilIfEmpty).joined().nilIfEmpty ?? "contact"
                return "\(name).vcf"
            } else {
                return "attachment"
            }
        }
        var data: Data? {
            if let url = url {
                return try? Data.smartContents(of: url)
            } else if case .contact(let contact) = self {
                return try? CNContactVCardSerialization.data(with: [contact])
            } else {
                return nil
            }
        }
        var asChatAttachment: ChatAttachment? {
            guard let data = data,
                  let compressed = try? data.compressed(with: compression) else { return nil }
            log.debug("Compressed size is \(compressed.count) bytes vs \(data.count) bytes uncompressed")
            return ChatAttachment(
                type: type,
                name: fileName,
                content: .data(compressed),
                compression: compression
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
                    TextField("Message \(channel.displayName(with: network))...", text: $draft, onCommit: sendDraft)
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
            controller.send(content: draft, on: channel, attaching: attachments, replyingTo: replyingToMessageId)
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

#Preview {
    let controller = ChatController(transport: MockTransport())
    let messages = Messages()
    let network = Network(messages: messages)
    let replyingToMessageId: UUID? = nil
    
    return MessageComposeView(channel: .global, controller: controller, replyingToMessageId: .constant(replyingToMessageId))
        .environmentObject(messages)
        .environmentObject(network)
}
