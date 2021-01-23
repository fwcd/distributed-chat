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
    
    var body: some View {
        Text("TODO")
    }
}

struct BubbleMessageView_Previews: PreviewProvider {
    static var previews: some View {
        BubbleMessageView(message: ChatMessage(author: ChatUser(name: "Alice"), content: "Test"))
    }
}
