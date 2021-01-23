//
//  AutoFocusTextField.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/23/21.
//

import SwiftUI
import UIKit

struct AutoFocusTextField: UIViewRepresentable {
    let placeholder: String
    @Binding var text: String
    var onCommit: (() -> Void)?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, onCommit: onCommit)
    }
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.delegate = context.coordinator
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<AutoFocusTextField>) {
        uiView.placeholder = placeholder
        uiView.text = text
        context.coordinator.onCommit = onCommit
        
        if !context.coordinator.isFirstResponder {
            uiView.becomeFirstResponder()
        }
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        var isFirstResponder: Bool = false
        var onCommit: (() -> Void)?
        
        init(text: Binding<String>, onCommit: (() -> Void)?) {
            _text = text
            self.onCommit = onCommit
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            onCommit?()
            return onCommit == nil
        }
    }
}
