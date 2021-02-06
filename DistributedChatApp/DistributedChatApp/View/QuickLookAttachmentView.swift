//
//  ImageAttachmentView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 2/2/21.
//

import DistributedChat
import SwiftUI

struct QuickLookAttachmentView<Content>: View where Content: View {
    private let attachment: ChatAttachment
    private let content: () -> Content
    
    @State private var quickLookShown: Bool = false
    @State private var shareSheetShown: Bool = false
    
    var body: some View {
        Button(action: { quickLookShown = true }) {
            content()
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
                ShareSheet(items: [attachment.url?.smartResolved].compactMap { $0 })
            }
        }
    }
    
    init(attachment: ChatAttachment, @ViewBuilder content: @escaping () -> Content) {
        self.attachment = attachment
        self.content = content
    }
}

struct QuickLookAttachmentView_Previews: PreviewProvider {
    static var previews: some View {
        QuickLookAttachmentView(attachment: ChatAttachment(name: "test.txt", url: URL(string: "data:text/plain;base64,dGVzdDEyMwo=")!)) {
            Text("Test")
        }
    }
}
