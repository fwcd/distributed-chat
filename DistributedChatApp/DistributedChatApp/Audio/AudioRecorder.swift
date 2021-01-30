//
//  AudioRecorder.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/30/21.
//

import AVFoundation
import Foundation
import Logging

fileprivate let log = Logger(label: "DistributedChatApp.AudioRecorder")

/// An Opus-based audio recorder that writes to a custom file in Recordings.
class AudioRecorder: NSObject, AVAudioRecorderDelegate {
    private let recorder: AVAudioRecorder
    private let onFinishRecording: () -> Void
    let url: URL
    
    init(name: String, onFinishRecording: @escaping () -> Void) throws {
        self.onFinishRecording = onFinishRecording
        url = persistenceFileURL(path: "Recordings/\(name)-\(UUID()).opus")
        recorder = try AVAudioRecorder(url: url, settings: [
            AVEncoderAudioQualityKey: AVAudioQuality.low.rawValue,
            AVNumberOfChannelsKey: 1,
            AVFormatIDKey: kAudioFormatOpus,
            AVSampleRateKey: 24_000.0 // Hz
        ])
        
        super.init()
        recorder.delegate = self
    }
    
    func record() {
        recorder.prepareToRecord()
        recorder.record()
    }
    
    func stop() {
        recorder.stop()
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully: Bool) {
        if successfully {
            onFinishRecording()
        } else {
            log.warning("Did not successfully finish recording.")
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        log.error("An encode error occurred: \(error.map { "\($0)" } ?? "?")")
    }
}
