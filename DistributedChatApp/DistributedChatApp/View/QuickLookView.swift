//
//  QuickLookView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/24/21.
//

import SwiftUI
import UIKit
import QuickLook

struct QuickLookView<I>: UIViewControllerRepresentable where I: QLPreviewItem {
    let item: I
    
    func makeCoordinator() -> Coordinator {
        Coordinator(item: item)
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let vc = QLPreviewController()
        vc.delegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        // Do nothing
    }
    
    class Coordinator: NSObject, QLPreviewControllerDelegate, QLPreviewControllerDataSource {
        private let item: I
        
        init(item: I) {
            self.item = item
        }
        
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            1
        }
        
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            item
        }
    }
}
