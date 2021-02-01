//
//  FileAttachmentView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/30/21.
//

import DistributedChat
import SwiftUI

struct FileAttachmentView: View {
    let attachment: ChatAttachment
    
    @State private var quickLookShown: Bool = false
    @State private var shareSheetShown: Bool = false
    
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
                    Button(action: { shareSheetShown = true }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: iconSize))
                    }
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
            .sheet(isPresented: $shareSheetShown) {
                ShareSheet(items: [attachment.url.smartResolved])
            }
        }
    }
}

struct FileAttachmentView_Previews: PreviewProvider {
    static var previews: some View {
        AttachmentView(attachment: ChatAttachment(name: "test.txt", url: URL(string: "data:text/plain;base64,dGVzdDEyMwo=")!))
    }
}
