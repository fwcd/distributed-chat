//
//  PlainMessageView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/23/21.
//

import DistributedChat
import SwiftUI

struct PlainMessageView: View {
    let message: ChatMessage
    
    var body: some View {
        Text("\(message.author.displayName): \(message.content)")
    }
}

struct PlainMessageView_Previews: PreviewProvider {
    static var previews: some View {
        PlainMessageView(message: ChatMessage(author: ChatUser(name: "Alice"), content: "Test"))
    }
}
