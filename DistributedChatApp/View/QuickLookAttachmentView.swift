//
//  ImageAttachmentView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 2/2/21.
//

import DistributedChatKit
import SwiftUI

struct QuickLookAttachmentView<Content>: View where Content: View {
    private let attachment: ChatAttachment
    private let content: () -> Content
    
    @State private var quickLookShown: Bool = false
    
    var body: some View {
        Button(action: { quickLookShown = true }) {
            content()
        }
        .sheet(isPresented: $quickLookShown) {
            NavigationStack {
                Group {
                    if let item = try? QuickLookAttachment(attachment: attachment) { QuickLookView(item: item)
                            .ignoresSafeArea()
                    }
                }
                .navigationTitle(attachment.name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        ShareLink(item: attachment, preview: SharePreview("Test")) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Close") {
                            quickLookShown = false
                        }
                        .foregroundColor(.primary)
                    }
                }
            }
        }
    }
    
    init(attachment: ChatAttachment, @ViewBuilder content: @escaping () -> Content) {
        self.attachment = attachment
        self.content = content
    }
}

#Preview {
    QuickLookAttachmentView(attachment: ChatAttachment(name: "test.txt", content: .url(URL(string: "data:text/plain;base64,dGVzdDEyMwo=")!))) {
        Text("Test")
    }
}
