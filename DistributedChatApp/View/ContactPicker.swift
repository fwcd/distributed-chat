//
//  ContactPicker.swift
//  Source: https://github.com/youjinp/SwiftUIKit/blob/a83aedd996bcb59ca846346bb507f090a7350e34/Sources/SwiftUIKit/views/ContactPicker.swift
//
//
//  Created by Youjin Phea on 27/06/20.
//

// MIT License
//
// Copyright (c) 2020 youjinp
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import SwiftUI
import ContactsUI

/**
Presents a CNContactPickerViewController view modally.

- Parameters:
    - showPicker: Binding variable for presenting / dismissing the picker VC
    - onSelectContact: Use this callback for single contact selection
    - onSelectContacts: Use this callback for multiple contact selections
*/
public struct ContactPicker: UIViewControllerRepresentable {
    @Binding var showPicker: Bool
    @State private var viewModel = ContactPickerViewModel()
    public var onSelectContact: ((_: CNContact) -> Void)?
    public var onSelectContacts: ((_: [CNContact]) -> Void)?
    public var onCancel: (() -> Void)?
    
    public init(showPicker: Binding<Bool>, onSelectContact: ((_: CNContact) -> Void)? = nil, onSelectContacts: ((_: [CNContact]) -> Void)? = nil, onCancel: (() -> Void)? = nil) {
        self._showPicker = showPicker
        self.onSelectContact = onSelectContact
        self.onSelectContacts = onSelectContacts
        self.onCancel = onCancel
    }
    
    public func makeUIViewController(context: UIViewControllerRepresentableContext<ContactPicker>) -> ContactPicker.UIViewControllerType {
        let dummy = _DummyViewController()
        viewModel.dummy = dummy
        return dummy
    }
    
    public func updateUIViewController(_ uiViewController: _DummyViewController, context: UIViewControllerRepresentableContext<ContactPicker>) {

        guard viewModel.dummy != nil else {
            return
        }
        
        // able to present when
        // 1. no current presented view
        // 2. current presented view is being dismissed
        let ableToPresent = viewModel.dummy.presentedViewController == nil || viewModel.dummy.presentedViewController?.isBeingDismissed == true
        
        // able to dismiss when
        // 1. cncpvc is presented
        let ableToDismiss = viewModel.vc != nil
        
        if showPicker && viewModel.vc == nil && ableToPresent {
            let pickerVC = CNContactPickerViewController()
            pickerVC.delegate = context.coordinator
            viewModel.vc = pickerVC
            viewModel.dummy.present(pickerVC, animated: true)
        } else if !showPicker && ableToDismiss {
            viewModel.dummy.dismiss(animated: true)
            self.viewModel.vc = nil
        }
    }
    
    public func makeCoordinator() -> ContactPickerCoordinator {
        if self.onSelectContacts != nil {
            return MultipleSelectionCoordinator(self)
        } else {
            return SingleSelectionCoordinator(self)
        }
    }
    
    public final class SingleSelectionCoordinator: NSObject, ContactPickerCoordinator {
        var parent : ContactPicker
        
        init(_ parent: ContactPicker){
            self.parent = parent
        }
        
        public func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
            parent.showPicker = false
            parent.onCancel?()
        }
        
        public func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            parent.showPicker = false
            parent.onSelectContact?(contact)
        }
    }
    
    public final class MultipleSelectionCoordinator: NSObject, ContactPickerCoordinator {
        var parent : ContactPicker
        
        init(_ parent: ContactPicker){
            self.parent = parent
        }
        
        public func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
            parent.showPicker = false
            parent.onCancel?()
        }
        
        public func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
            parent.showPicker = false
            parent.onSelectContacts?(contacts)
        }
    }
}

class ContactPickerViewModel {
    var dummy: _DummyViewController!
    var vc: CNContactPickerViewController?
}

public protocol ContactPickerCoordinator: CNContactPickerDelegate {}

public class _DummyViewController: UIViewController {}
