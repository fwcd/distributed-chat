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
    
    var body: some View {
        ZStack {
            Text("Hello")
                .foregroundColor(isMe ? .black : .white)
                .padding(10)
                .background(isMe
                    ? LinearGradient(gradient: Gradient(colors: [
                          Color(red: 0.9, green: 0.9, blue: 0.9),
                          Color(red: 0.9, green: 0.9, blue: 0.9)
                      ]), startPoint: .top, endPoint: .bottom)
                    : LinearGradient(gradient: Gradient(colors: [
                          Color(red: 0, green: 0.5, blue: 1),  // Blue
                          Color(red: 0, green: 0.4, blue: 0.7) // Darker blue
                      ]), startPoint: .top, endPoint: .bottom)
                )
                .cornerRadius(10)
        }
    }
}

struct BubbleMessageView_Previews: PreviewProvider {
    static let message = ChatMessage(author: ChatUser(name: "Alice"), content: "Test")
    static var previews: some View {
        VStack {
            BubbleMessageView(message: message, isMe: false)
            BubbleMessageView(message: message, isMe: true)
        }
    }
}
