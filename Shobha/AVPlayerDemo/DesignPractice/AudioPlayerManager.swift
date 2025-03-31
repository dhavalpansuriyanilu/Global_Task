//
//  AudioPlayerManager.swift
//  DesignPractice
//
//  Created by MacBook_Air_41 on 10/09/24.
//

import Foundation
import AVFoundation
import UIKit

class AudioPlayerManager {
    
    static let shared = AudioPlayerManager()
    private var wasPlayingBeforeBackground = false
    private var lastPlaybackTime: CMTime = CMTime.zero


    
    var player: AVPlayer?
    var isPlaying: Bool {
        return player?.timeControlStatus == .playing
    }
    
    private init() {
        // Initialize with any configurations needed
        setupAudioSession()
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)

    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
    
    func loadAudio(from url: URL) {
        stop() // Stop the current audio before loading new one
        player = AVPlayer(url: url)
    }
    
    func play() {
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    func stop() {
        pause()
        player?.seek(to: CMTime.zero)
    }
    
    func currentPlaybackTime() -> Double {
        guard let player = player else { return 0 }
        return CMTimeGetSeconds(player.currentTime())
    }
    
    func audioDuration() -> Double {
        guard let player = player, let currentItem = player.currentItem else { return 0 }
        return CMTimeGetSeconds(currentItem.duration)
    }
    
    @objc func didEnterBackground() {
        if isPlaying {
            wasPlayingBeforeBackground = true
            lastPlaybackTime = player?.currentTime() ?? CMTime.zero
            pause() // Pause audio when entering background
        } else {
            wasPlayingBeforeBackground = false
        }
        print("App entred in Background")
    }
    
    // entering foreground
    @objc private func willEnterForeground() {
        if wasPlayingBeforeBackground {
            player?.seek(to: lastPlaybackTime) // Seek to where it left off
            play() // Resume playing
        }
        print("App entred in foreground")
    }
}
