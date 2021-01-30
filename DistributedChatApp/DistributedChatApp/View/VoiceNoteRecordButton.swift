//
//  VoiceNoteRecordButton.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/30/21.
//

import SwiftUI

struct VoiceNoteRecordButton: View {
    let onFinishRecording: (URL) -> Void
    
    @StateObject private var recorder = try! AudioRecorder(name: "voiceNote")
    
    @ViewBuilder
    var body: some View {
        HStack {
            if recorder.isRecording {
                HStack {
                    Image(systemName: "stop.fill")
                        .scaleEffect(4.0)
                }
                    .foregroundColor(.red)
            } else {
                Image(systemName: "mic.fill")
                    .foregroundColor(.blue)
            }
        }
        .onReceive(recorder.$isCompleted) {
            if $0 {
                onFinishRecording(recorder.url)
            }
        }
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { isRecording in
                recorder.isRecording = isRecording
            }) {}
    }
}

struct VoiceNoteRecordButton_Previews: PreviewProvider {
    static var previews: some View {
        VoiceNoteRecordButton { _ in }
    }
}
