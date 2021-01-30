//
//  AudioPlayer.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/30/21.
//

import AVFoundation
import Combine
import Foundation

class AudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    private var player: AVAudioPlayer? = nil
    
    var url: URL? {
        get { player?.url }
        set { player = newValue.flatMap {
            print($0)
//            let data = try! Data(contentsOf: $0)
//            print("Got it")
//            let newPlayer = try! AVAudioPlayer(contentsOf: $0)
//            newPlayer.delegate = self
            return nil
        } }
    }
    @Published var isPlaying: Bool = false {
        didSet {
            if isPlaying {
                player?.play()
            } else {
                player?.pause()
            }
        }
    }
}
