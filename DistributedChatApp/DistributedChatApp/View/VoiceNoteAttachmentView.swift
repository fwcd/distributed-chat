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
    let color: Color
    
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
                .font(.system(size: 24))
                if let url = player.url {
                    WaveformView(url: url, color: color)
                        .frame(width: 80, height: 30)
                }
            }
        }
        .onAppear {
            if let url = attachment.url {
                player.url = url
            }
        }
    }
}
