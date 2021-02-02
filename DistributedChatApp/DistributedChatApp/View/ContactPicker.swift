//
//  ContactPicker.swift
//  DistributedChatApp
//
//  Created by Fredrik on 2/2/21.
//

import SwiftUI
import UIKit
import Contacts
import ContactsUI

struct ContactPicker: SimpleUIViewControllerRepresentable {
    let onSelect: (CNContact) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onSelect: onSelect)
    }
    
    func makeUIViewController(coordinator: Coordinator) -> CNContactPickerViewController {
        let vc = CNContactPickerViewController()
        vc.delegate = coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {
        // Do nothing
    }
    
    class Coordinator: NSObject, CNContactPickerDelegate {
        private let onSelect: (CNContact) -> Void
        
        init(onSelect: @escaping (CNContact) -> Void) {
            self.onSelect = onSelect
        }
        
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            onSelect(contact)
        }
    }
}
