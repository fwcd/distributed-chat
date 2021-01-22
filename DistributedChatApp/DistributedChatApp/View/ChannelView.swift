//
//  ChannelView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/22/21.
//

import SwiftUI

struct ChannelView: View {
    let channel: Channel
    
    var body: some View {
        Text("TODO")
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChannelView(channel: Channel(name: "Test", messages: []))
    }
}
