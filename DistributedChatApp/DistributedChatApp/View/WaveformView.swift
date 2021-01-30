//
//  WaveformView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/30/21.
//

import SwiftUI
import UIKit
import FDWaveformView

struct WaveformView: UIViewRepresentable {
    let url: URL
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> some UIView {
        let view = FDWaveformView()
        view.delegate = context.coordinator
        view.audioURL = url.smartResolved
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        // TODO
    }
    
    class Coordinator: NSObject, FDWaveformViewDelegate {
        // TODO
    }
}
