//
//  ViewController.swift
//  SilenceDetectDemo
//
//  Created by MacBook_Air_41 on 18/09/24.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate {
    
    var audioRecorder: AVAudioRecorder!
    var recordingSession: AVAudioSession!
    var timer: Timer?
    var silenceThreshold: Float = -30.0
    var silenceDurations: [(start: TimeInterval, end: TimeInterval)] = [] // Array to store periods of silence
    
    var silenceStartTime: TimeInterval? // Store when silence starts
    var currentSilenceDuration: TimeInterval = 0.0 // Store silence duration
    var backgroundMusicPlayer: AVAudioPlayer?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        // Setup UI
        let recordButton = UIButton(type: .system)
        recordButton.frame = CGRect(x: 100, y: 200, width: 200, height: 50)
        recordButton.setTitle("Start Recording", for: .normal)
        recordButton.addTarget(self, action: #selector(startRecording), for: .touchUpInside)
        view.addSubview(recordButton)
        
        let stopButton = UIButton(type: .system)
        stopButton.frame = CGRect(x: 100, y: 300, width: 200, height: 50)
        stopButton.setTitle("Stop Recording", for: .normal)
        stopButton.addTarget(self, action: #selector(stopRecording), for: .touchUpInside)
        view.addSubview(stopButton)
        
        // microphone access
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission { allowed in
                if !allowed {
                    print("Permission denied")
                }
            }
        } catch {
            print("Failed to set up session: \(error.localizedDescription)")
        }
    }
    
    @objc func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.wav")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.isMeteringEnabled = true
            audioRecorder.record()
            
            // Start monitoring for silence
            startSilenceDetection()
           // playBackgroundMusic(named: "Hungry4.mp3")

        } catch {
            print("Failed to start recording: \(error.localizedDescription)")
        }
    }
    
    func startSilenceDetection() {
        // Set up a timer to check audio levels every 0.1 seconds
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(checkAudioLevels), userInfo: nil, repeats: true)
    }
    
    @objc func checkAudioLevels2() {
        audioRecorder.updateMeters() // Update the metering
        
        let currentAmplitude = audioRecorder.averagePower(forChannel: 0)
        let normalizedAmplitude = pow(10, currentAmplitude / 20.0) // Convert to linear scale

        if normalizedAmplitude < pow(10, silenceThreshold / 20.0) {
            // Detected silence
            if silenceStartTime == nil {
                silenceStartTime = audioRecorder.currentTime
            }
            currentSilenceDuration += 0.1

            if let silenceStart = silenceStartTime, backgroundMusicPlayer?.isPlaying == true 
            {
                backgroundMusicPlayer?.pause()
                print("Paused background music during silence from \(silenceStart)")
            }
            
        } else {
            // Detected sound after a period of silence
            if let silenceStart = silenceStartTime, currentSilenceDuration >= 1.0 {
                let silenceEndTime = audioRecorder.currentTime
                silenceDurations.append((start: silenceStart, end: silenceEndTime))
                print("Silence detected from \(silenceStart) to \(silenceEndTime)")
            }

            if backgroundMusicPlayer?.isPlaying == false {
                backgroundMusicPlayer?.play()
                print("Resumed background music after silence.")
            }

            silenceStartTime = nil
            currentSilenceDuration = 0.0
        }
    }

//    @objc func checkAudioLevels() {
//        audioRecorder.updateMeters() // Update the metering
//        
//        let currentAmplitude = audioRecorder.averagePower(forChannel: 0)
//        let normalizedAmplitude = pow(10, currentAmplitude / 20.0) // Convert to linear scale
//        
//        if normalizedAmplitude < pow(10, silenceThreshold / 20.0) {
//            // Detected silence
//            if silenceStartTime == nil {
//                silenceStartTime = audioRecorder.currentTime
//                
//                // Pause the cat audio when silence starts
//                if backgroundMusicPlayer?.isPlaying == true {
//                    backgroundMusicPlayer?.pause()
//                    print("Paused cat audio at silence start.")
//                }
//            }
//            currentSilenceDuration += 0.1
//        } else {
//            // Detected sound after a period of silence
//            if let silenceStart = silenceStartTime, currentSilenceDuration >= 1.0 {
//                let silenceEndTime = audioRecorder.currentTime
//                silenceDurations.append((start: silenceStart, end: silenceEndTime))
//                print("Silence detected from \(silenceStart) to \(silenceEndTime)")
//                
//                // Resume the cat audio when sound is detected after silence
//                if backgroundMusicPlayer?.isPlaying == false {
//                    backgroundMusicPlayer?.play()
//                    print("Resumed cat audio at silence end.")
//                }
//            }
//            silenceStartTime = nil
//            currentSilenceDuration = 0.0
//        }
//    }

    
    @objc func checkAudioLevels() {
        audioRecorder.updateMeters() // Update the metering
        
        let currentAmplitude = audioRecorder.averagePower(forChannel: 0)
        let normalizedAmplitude = pow(10, currentAmplitude / 20.0) // Convert to linear scale
        
        // Debug: Print current amplitude and normalized amplitude
        // print("Current Amplitude: \(currentAmplitude)")
        // print("Normalized Amplitude: \(normalizedAmplitude)")
        
        if normalizedAmplitude < pow(10, silenceThreshold / 20.0) {
            // Detected silence
            if silenceStartTime == nil {
                silenceStartTime = audioRecorder.currentTime
            }
            currentSilenceDuration += 0.1
        } else {
            // Detected sound after a period of silence
            if let silenceStart = silenceStartTime, currentSilenceDuration >= 1.0 {
                let silenceEndTime = audioRecorder.currentTime
                silenceDurations.append((start: silenceStart, end: silenceEndTime))
                print("Silence detected from \(silenceStart) to \(silenceEndTime)")
            }
            silenceStartTime = nil
            currentSilenceDuration = 0.0
        }
    }
    
    @objc func stopRecording1() {
        audioRecorder.stop()
        timer?.invalidate()
        
        if silenceDurations.isEmpty {
            print("No silence periods detected.")
        } else {
            // Correct and output silence periods
            let correctedSilences = correctSilencePeriods(silenceDurations)
            for silence in correctedSilences {
                print("Silence from \(silence.start) to \(silence.end)")
            }
        }
        
        checkFileSize()
//        playBackgroundMusic(named: "Hungry4.mp3")
    }
    
    
    @objc func stopRecording2() {
        audioRecorder.stop()
        timer?.invalidate()
        
        if silenceDurations.isEmpty {
            print("No silence periods detected.")
        } else {
            // Correct and output silence periods
            let correctedSilences = correctSilencePeriods(silenceDurations)
            for silence in correctedSilences {
                print("Silence from \(silence.start) to \(silence.end)")
            }
            
            // Play background music first
            playBackgroundMusic(named: "Hungry4.mp3")
            
            // Now handle pausing/resuming the cat audio based on silence periods
            handleCatAudioBasedOnSilence(silenceDurations: correctedSilences)
        }
        
        checkFileSize()
    }
    
    @objc func stopRecording() {
        audioRecorder.stop()  // Stop the recording
        timer?.invalidate()   // Invalidate any running timers

        // Check if there are detected silence periods
        if silenceDurations.isEmpty {
            print("No silence periods detected.")
        } else {
            // Correct and output silence periods
            let correctedSilences = correctSilencePeriods(silenceDurations)
            for silence in correctedSilences {
                print("Silence from \(silence.start) to \(silence.end)")
            }
            
            // Play background music first
            playBackgroundMusic(named: "Hungry4.mp3")
            
            // Handle pausing/resuming based on silence periods
            handleCatAudioBasedOnSilence(silenceDurations: correctedSilences)
        }
        
        // Stop the cat audio when the recorded audio duration completes
        stopCatAudioAfterRecordingDuration()
        
        checkFileSize()  // Check file size as part of the final process
    }
    
    func stopCatAudioAfterRecordingDuration() {
        guard let recordedAudioURL = audioRecorder?.url else { return }
        
        let asset = AVAsset(url: recordedAudioURL)
        let durationInSeconds = CMTimeGetSeconds(asset.duration)
        
        // Stop the cat audio after the recording duration completes
        DispatchQueue.main.asyncAfter(deadline: .now() + durationInSeconds) {
            self.backgroundMusicPlayer?.stop()  // Stop the background music
            print("Stopped cat audio after \(durationInSeconds) seconds.")
        }
    }


    
    func handleCatAudioBasedOnSilence(silenceDurations: [(start: TimeInterval, end: TimeInterval)]) {
        guard !silenceDurations.isEmpty else { return }
        
        for silence in silenceDurations {
            let startDelay = silence.start
            let endDelay = silence.end
            
            // Pause the cat audio at the start of the silence
            DispatchQueue.main.asyncAfter(deadline: .now() + startDelay) {
                self.backgroundMusicPlayer?.pause()
                print("Paused cat audio at silence start: \(silence.start) seconds.")
            }
            
            // Resume the cat audio at the end of the silence
            DispatchQueue.main.asyncAfter(deadline: .now() + endDelay) {
                self.backgroundMusicPlayer?.play()
                print("Resumed cat audio at silence end: \(silence.end) seconds.")
            }
        }
    }


    
    func handleCatAudioBasedOnSilence2(silenceDurations: [(start: TimeInterval, end: TimeInterval)]) {
        guard !silenceDurations.isEmpty else { return }
        
        for silence in silenceDurations {
            let startDelay = silence.start
            let endDelay = silence.end
            
            // Pause the cat audio at the start of the silence
            DispatchQueue.main.asyncAfter(deadline: .now() + startDelay) {
                self.backgroundMusicPlayer?.pause()
                print("Paused cat audio at silence start: \(silence.start) seconds.")
            }
            
            // Resume the cat audio at the end of the silence
            DispatchQueue.main.asyncAfter(deadline: .now() + endDelay) {
                self.backgroundMusicPlayer?.play()
                print("Resumed cat audio at silence end: \(silence.end) seconds.")
            }
        }
    }
    
   
    
    
    // Function to play background music
    func playBackgroundMusic(named filename: String) {
        if let musicURL = Bundle.main.url(forResource: filename, withExtension: nil) {
            do {
                backgroundMusicPlayer = try AVAudioPlayer(contentsOf: musicURL)
                backgroundMusicPlayer?.numberOfLoops = -1 // Loop infinitely
                backgroundMusicPlayer?.play()
            } catch {
                print("Could not play background music file: \(filename)")
            }
        }
    }
    
    func correctSilencePeriods(_ periods: [(start: TimeInterval, end: TimeInterval)]) -> [(start: TimeInterval, end: TimeInterval)] {
        let sortedPeriods = periods.sorted { $0.start < $1.start }
        
        var mergedPeriods: [(start: TimeInterval, end: TimeInterval)] = []
        for period in sortedPeriods {
            if var last = mergedPeriods.last {
                if period.start <= last.end {
                    // Merge overlapping intervals
                    last.end = max(last.end, period.end)
                    mergedPeriods[mergedPeriods.count - 1] = last
                } else {
                    mergedPeriods.append(period)
                }
            } else {
                mergedPeriods.append(period)
            }
        }
        
        return mergedPeriods
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func checkFileSize() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.wav")
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: audioFilename.path)
            let fileSize = attributes[FileAttributeKey.size] as! UInt64
            print("File size: \(fileSize) bytes")
        } catch {
            print("Failed to get file attributes: \(error.localizedDescription)")
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            print("Recording finished successfully.")
        } else {
            print("Recording failed.")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopRecording()
    }
}
