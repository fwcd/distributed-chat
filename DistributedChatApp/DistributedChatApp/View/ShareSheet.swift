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
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // Do nothing
    }
}
