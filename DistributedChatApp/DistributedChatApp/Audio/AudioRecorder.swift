//
//  AudioRecorder.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/30/21.
//

import AVFoundation
import Foundation
import Combine
import Logging

fileprivate let log = Logger(label: "DistributedChatApp.AudioRecorder")

/// An Opus-based audio recorder that writes to a custom file in Recordings.
class AudioRecorder: NSObject, ObservableObject, AVAudioRecorderDelegate {
    private let recorder: AVAudioRecorder
    
    @Published var isRecording: Bool = false {
        didSet {
            if isRecording {
                record()
            } else {
                stop()
            }
        }
    }
    @Published private(set) var isCompleted: Bool = false
    let url: URL
    
    init(name: String) throws {
        url = persistenceFileURL(path: "Recordings/\(name).opus")
        recorder = try AVAudioRecorder(url: url, settings: [
            AVEncoderAudioQualityKey: AVAudioQuality.low.rawValue,
            AVNumberOfChannelsKey: 1,
            AVFormatIDKey: kAudioFormatOpus,
            AVSampleRateKey: 24_000.0 // Hz
        ])
        
        super.init()
        recorder.delegate = self
    }
    
    private func record() {
        recorder.prepareToRecord()
        recorder.record()
        isCompleted = false
    }
    
    private func stop() {
        recorder.stop()
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully: Bool) {
        if successfully {
            isCompleted = true
        } else {
            log.warning("Did not successfully finish recording.")
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        log.error("An encode error occurred: \(error.map { "\($0)" } ?? "?")")
    }
}
