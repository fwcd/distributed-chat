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
    private var player: AVAudioPlayer? = nil {
        didSet {
            isReady = player != nil
        }
    }
    
    var url: URL? = nil {
        willSet {
            if let url = newValue,
               let data = try? Data.smartContents(of: url),
               let player = try? AVAudioPlayer(data: data) {
                player.delegate = self
                self.player = player
            } else {
                player = nil
            }
        }
    }
    
    @Published var isReady: Bool = false
    @Published var isPlaying: Bool = false {
        willSet {
            if newValue != isPlaying {
                if newValue {
                    player?.play()
                } else {
                    player?.pause()
                }
            }
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
    }
}
