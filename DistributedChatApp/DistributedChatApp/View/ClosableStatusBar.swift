//
//  ClosableStatusBar.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/24/21.
//

import SwiftUI

struct ClosableStatusBar<V>: View where V: View {
    let onClose: () -> Void
    let content: () -> V
    
    var body: some View {
        HStack {
            content()
            Spacer()
            Button(action: onClose) {
                Image(systemName: "xmark.circle")
            }
        }
    }
}

struct ClosableStatusBar_Previews: PreviewProvider {
    static var previews: some View {
        ClosableStatusBar(onClose: {}) {
            Text("Test")
        }
    }
}
