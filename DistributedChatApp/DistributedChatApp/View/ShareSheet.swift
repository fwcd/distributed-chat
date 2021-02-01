//
//  ShareSheet.swift
//  DistributedChatApp
//
//  Created by Fredrik on 2/1/21.
//

import SwiftUI
import UIKit
import Logging

fileprivate let log = Logger(label: "DistributedChatApp.ShareSheet")

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    var onComplete: (() -> Void)? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        makeUIViewControllerImpl()
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // Do nothing
    }
    
    /// Presents the share sheet directly through UIKit.
    func present() {
        let vc = makeUIViewControllerImpl()
        UIApplication.shared.windows.first?.rootViewController?.present(vc, animated: true, completion: nil)
    }
    
    private func makeUIViewControllerImpl() -> UIActivityViewController {
        let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        vc.completionWithItemsHandler = { _, _, _, error in
            if let error = error {
                log.error("Error after completing share sheet: \(error)")
                return
            }
            onComplete?()
        }
        return vc
    }
}
