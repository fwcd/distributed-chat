//
//  MessageComposeView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/24/21.
//

import DistributedChat
import SwiftUI

struct MessageComposeView: View {
    let channelName: String?
    let controller: ChatController
    @Binding var replyingToMessageId: UUID?
    
    @EnvironmentObject var messages: Messages
    @State private var draft: String = ""
    
    var body: some View {
        if let id = replyingToMessageId, let message = messages[id] {
            HStack {
                Text("Replying to")
                PlainMessageView(message: message)
                Spacer()
                Button(action: {
                    replyingToMessageId = nil
                }) {
                    Image(systemName: "xmark.circle")
                }
            }
        }
        HStack {
            TextField("Message #\(channelName ?? globalChannelName)...", text: $draft, onCommit: sendDraft)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button(action: sendDraft) {
                Text("Send")
                    .fontWeight(.bold)
            }
        }
    }
    
    private func sendDraft() {
        if !draft.isEmpty {
            controller.send(content: draft, on: channelName, replyingTo: replyingToMessageId)
            draft = ""
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
