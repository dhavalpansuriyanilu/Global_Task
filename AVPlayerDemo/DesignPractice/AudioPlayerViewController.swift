//
//  AudioPlayerViewController.swift
//  DesignPractice
//
//  Created by MacBook_Air_41 on 09/09/24.
//

import UIKit
import AVFoundation


class AudioPlayerViewController: UIViewController {
    
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var progressSlider: UISlider!
    
    var audioURL: URL?
    private var timeObserverToken: Any?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = audioURL {
            AudioPlayerManager.shared.loadAudio(from: url)
        }
        // Load the audio file from the bundle
        if let audioPath = Bundle.main.path(forResource: "dog_barking_0", ofType: "wav") {
            let audioURL = URL(fileURLWithPath: audioPath)
            AudioPlayerManager.shared.loadAudio(from: audioURL)
        } else {
            print("Audio file not found in the bundle")
        }
        progressSlider.value = 0
        currentTimeLabel.text = "00:00"
        // Timer to update UI with current time
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updatePlaybackUI), userInfo: nil, repeats: true)
//        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
//    @objc func didEnterBackground() {
//        AudioPlayerManager.shared.stop() // Stop the audio when the app goes to the background
//        print("App entred in Background")
//    }
    
    @IBAction func playPauseTapped(_ sender: UIButton) {
        AudioPlayerManager.shared.togglePlayPause()
        if !AudioPlayerManager.shared.isPlaying {
            resetSliderAndTime()
        } else {
            updatePlayPauseButton()
        }
        if !AudioPlayerManager.shared.isPlaying && progressSlider.value == 0 {
            if let audioURL = audioURL ?? Bundle.main.url(forResource: "dog_barking_0", withExtension: "wav") {
                AudioPlayerManager.shared.loadAudio(from: audioURL)
            }
            AudioPlayerManager.shared.play()
        }
        updatePlayPauseButton()
    }

   
    @IBAction func progressSliderChanged(_ sender: UISlider) {
        let duration = AudioPlayerManager.shared.audioDuration()
        let newTime = Double(sender.value) * duration
        AudioPlayerManager.shared.player?.seek(to: CMTime(seconds: newTime, preferredTimescale: 1))
    }
    
    
    @objc func updatePlaybackUI() {
        let currentTime = AudioPlayerManager.shared.currentPlaybackTime()
        let duration = AudioPlayerManager.shared.audioDuration()
        
        currentTimeLabel.text = formatTime(seconds: currentTime)
        durationLabel.text = formatTime(seconds: duration)
        
        if duration > 0 {
            progressSlider.value = Float(currentTime / duration)
        }
        updatePlayPauseButton()
        
        if currentTime >= duration {
            resetSliderAndTime()
        }
    }
    
    private func resetSliderAndTime() {
           progressSlider.value = 0
           currentTimeLabel.text = "00:00"
       }
    
    private func updatePlayPauseButton() {
        let title = AudioPlayerManager.shared.isPlaying ? "Pause" : "Play"
        playPauseButton.setTitle(title, for: .normal)
    }
    
    private func formatTime(seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let seconds = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
