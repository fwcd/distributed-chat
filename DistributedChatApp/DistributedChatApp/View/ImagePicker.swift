//
//  ImagePicker.swift
//  DistributedChatApp
//
//  Created by Fredrik on 2/1/21.
//

import SwiftUI
import UIKit
import Logging

fileprivate let log = Logger(label: "DistributedChatApp.ImagePicker")

struct ImagePicker: UIViewControllerRepresentable {
    let sourceType: SourceType
    let onComplete: (URL?) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onComplete: onComplete)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let vc = UIImagePickerController()
        vc.sourceType = sourceType.usingUIKit
        vc.allowsEditing = true
        vc.delegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // Do nothing
    }
    
    enum SourceType {
        case photoLibrary
        case savedPhotosAlbum
        case camera
        
        var usingUIKit: UIImagePickerController.SourceType {
            switch self {
            case .photoLibrary:
                return .photoLibrary
            case .savedPhotosAlbum:
                return .savedPhotosAlbum
            case .camera:
                return .camera
            }
        }
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        private let onComplete: (URL?) -> Void
        
        init(onComplete: @escaping (URL?) -> Void) {
            self.onComplete = onComplete
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if picker.sourceType == .camera, let image = info[.originalImage] as? UIImage {
                let url = persistenceFileURL(path: "CameraRoll/\(UUID()).jpg")
                do {
                    try image.jpegData(compressionQuality: 0.4)?.smartWrite(to: url)
                    onComplete(url)
                } catch {
                    log.error("Could not write image \(error)")
                    onComplete(nil)
                }
            } else if let url = info[.imageURL] as? URL {
                onComplete(url)
            } else {
                log.warning("No image picked")
                onComplete(nil)
            }
        }
    }
}
