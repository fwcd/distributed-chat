//
//  BubbleMessageView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/23/21.
//

import DistributedChat
import SwiftUI

struct BubbleMessageView: View {
    let message: ChatMessage
    let isMe: Bool
    var onPressRepliedMessage: ((UUID) -> Void)? = nil
    
    @EnvironmentObject private var messages: Messages
    
    var body: some View {
        VStack(alignment: isMe ? .trailing : .leading) {
            if let id = message.repliedToMessageId, let referenced = messages[id] {
                Button(action: {
                    onPressRepliedMessage?(id)
                }) {
                    HStack {
                        Image(systemName: "arrowshape.turn.up.backward")
                        PlainMessageView(message: referenced)
                    }
                    .foregroundColor(.secondary)
                }
            }
            ZStack {
                VStack(alignment: .leading) {
                    if message.isEncrypted {
                        Image(systemName: "lock.fill")
                        Text("Encrypted")
                    } else {
                        HStack {
                            if message.wasEncrypted ?? false {
                                Image(systemName: "lock")
                            }
                            Text(message.author.displayName)
                        }
                            .font(.caption)
                            .foregroundColor(isMe ? .white : .gray)
                        if let content = message.content.asText, !content.isEmpty {
                            Text(content)
                        }
                        ForEach(message.attachments ?? []) { attachment in
                            AttachmentView(attachment: attachment, voiceNoteColor: isMe ? .white : .black)
                        }
                    }
                }
                .foregroundColor(isMe ? .white : .black)
                .padding(10)
                .background(isMe
                    ? LinearGradient(gradient: Gradient(colors: [
                            Color(red: 0, green: 0.5, blue: 1),  // Blue
                            Color(red: 0, green: 0.4, blue: 0.7) // Darker blue
                        ]), startPoint: .top, endPoint: .bottom)
                    : LinearGradient(gradient: Gradient(colors: [
                            Color(red: 0.9, green: 0.9, blue: 0.9),
                            Color(red: 0.9, green: 0.9, blue: 0.9)
                        ]), startPoint: .top, endPoint: .bottom)
                )
                .cornerRadius(10)
            }
        }
    }
}

struct BubbleMessageView_Previews: PreviewProvider {
    static let message1 = ChatMessage(author: ChatUser(name: "Alice"), content: "Hi!")
    static let message2 = ChatMessage(author: ChatUser(name: "Bob"), content: "This is a long\nmultiline message!", repliedToMessageId: message1.id, wasEncrypted: true)
    static let message3 = ChatMessage(author: ChatUser(name: "Charles"), content: .encrypted(ChatCryptoCipherData(sealed: Data(), signature: Data(), ephemeralPublicKey: Data())), repliedToMessageId: message1.id)
    @StateObject static var messages = Messages(messages: [
        message1,
        message2,
        message3
    ])
    static var previews: some View {
        VStack {
            BubbleMessageView(message: message1, isMe: false)
            BubbleMessageView(message: message2, isMe: true)
            BubbleMessageView(message: message3, isMe: true)
        }
        .environmentObject(messages)
    }
}
