//
//  VoiceNoteAttachmentView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/30/21.
//

import AVFoundation
import AVKit
import DistributedChat
import SwiftUI

struct VoiceNoteAttachmentView: View {
    let attachment: ChatAttachment
    
    @StateObject private var player = AudioPlayer()
    
    var body: some View {
        HStack {
            if player.isReady {
                Button(action: {
                    player.isPlaying = !player.isPlaying
                }) {
                    if player.isPlaying {
                        Image(systemName: "pause.fill")
                    } else {
                        Image(systemName: "play.fill")
                    }
                }
                if let url = player.url {
                    WaveformView(url: url, color: .white)
                        .frame(width: 80)
                }
            }
        }
        .onAppear {
            player.url = attachment.url
        }
    }
}
