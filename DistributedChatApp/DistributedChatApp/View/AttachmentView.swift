//
//  AttachmentView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/24/21.
//

import DistributedChat
import SwiftUI

struct AttachmentView: View {
    let attachment: ChatAttachment
    
    @State private var quickLookShown: Bool = false
    
    var body: some View {
        Button(action: { quickLookShown = true }) {
            HStack {
                Image(systemName: "doc.fill")
                Text(attachment.name)
            }
        }
        .sheet(isPresented: $quickLookShown) {
            VStack {
                HStack {
                    Spacer()
                    Button(action: { quickLookShown = false }) {
                        Text("Close")
                            .foregroundColor(.primary)
                    }
                }
                .padding(15)
                
                if let item = try? QuickLookAttachment(attachment: attachment) {
                    QuickLookView(item: item)
                }
            }
        }
    }
}

struct AttachmentView_Previews: PreviewProvider {
    static var previews: some View {
        AttachmentView(attachment: ChatAttachment(name: "test.txt", url: URL(string: "data:text/plain;base64,dGVzdDEyMwo=")!))
    }
}
