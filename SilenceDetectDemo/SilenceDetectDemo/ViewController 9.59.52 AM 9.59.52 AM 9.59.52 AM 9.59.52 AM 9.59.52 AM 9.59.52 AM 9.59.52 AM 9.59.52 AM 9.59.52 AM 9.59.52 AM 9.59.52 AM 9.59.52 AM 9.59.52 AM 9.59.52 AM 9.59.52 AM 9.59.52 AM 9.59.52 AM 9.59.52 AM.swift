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
            
        } catch {
            print("Failed to start recording: \(error.localizedDescription)")
        }
    }
    
    func startSilenceDetection() {
        // Set up a timer to check audio levels every 0.1 seconds
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(checkAudioLevels), userInfo: nil, repeats: true)
    }
    
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
    
    @objc func stopRecording() {
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
