//
//  View+RootSheet.swift
//  DistributedChatApp
//
//  Created by Fredrik on 2/2/21.
//

import SwiftUI
import UIKit

struct RootSheetModifier<Inner>: ViewModifier where Inner: SimpleUIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let inner: () -> Inner
    
    @State private var viewController: UIViewController? = nil
    
    func body(content: Content) -> some View {
        content.onChange(of: isPresented) {
            if $0 {
                let view = inner()
                let viewController = view.makeUIViewController(coordinator: view.makeCoordinator())
                UIApplication.shared.windows.first?.rootViewController?.present(viewController, animated: true, completion: nil)
                self.viewController = viewController
            } else {
                viewController?.dismiss(animated: true, completion: nil)
            }
        }
    }
}
