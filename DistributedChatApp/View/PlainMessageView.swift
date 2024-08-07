//
//  PlainMessageView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/23/21.
//

import DistributedChatKit
import SwiftUI

struct PlainMessageView: View {
    let message: ChatMessage
    
    var body: some View {
        Text("\(message.author.displayName): \(message.displayContent)")
    }
}

#Preview {
    PlainMessageView(message: ChatMessage(author: ChatUser(name: "Alice"), content: "Test"))
}
