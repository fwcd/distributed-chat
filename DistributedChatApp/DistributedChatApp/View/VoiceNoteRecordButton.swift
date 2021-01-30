//
//  VoiceNoteRecordButton.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/30/21.
//

import SwiftUI

struct VoiceNoteRecordButton: View {
    @State private var isRecording: Bool = false
    @State private var isCompleted: Bool = false
    
    var body: some View {
        HStack {
            if isRecording {
                Image(systemName: "stop.fill")
                    .foregroundColor(.red)
            } else if isCompleted {
                Image(systemName: "checkmark")
            } else {
                Image(systemName: "mic.fill")
                    .foregroundColor(.blue)
            }
        }
        .onLongPressGesture(minimumDuration: 1, pressing: { isRecording in
            self.isRecording = isRecording
        }) {
            isCompleted = true
        }
    }
}

struct VoiceNoteRecordButton_Previews: PreviewProvider {
    static var previews: some View {
        VoiceNoteRecordButton()
    }
}
