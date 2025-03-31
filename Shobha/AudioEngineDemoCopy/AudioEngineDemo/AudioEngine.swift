//
//  AudioEngine.swift
//  AudioEngineDemo
//
//  Created by MacBook_Air_41 on 13/09/24.
//

import Foundation
import AVFoundation
import UIKit

class AudioEngineManager {
    
    static let shared = AudioEngineManager()
    
    var audioEngine: AVAudioEngine!
    var audioFile: AVAudioFile?
    var audioPlayerNode = AVAudioPlayerNode()
    var isRecording = false
    
    private init() {
        setupAudioEngine()
        checkMicrophonePermission()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
    }
    
    @objc func didEnterBackground() {
        if let engine = audioEngine, engine.isRunning {
            engine.stop()
            audioPlayerNode.stop()
            print("Audio engine stopped due to backgrounding in singleton")
        }
    }

    func setupAudioEngine() {
        if audioEngine == nil {
            audioEngine = AVAudioEngine()
        }
    }
    
    func getAudioFileURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = "recorded_audio_\(Date().timeIntervalSince1970).wav"
        return documentsDirectory.appendingPathComponent(fileName)
    }

    // Start recording
    func startRecording1() -> URL? {
        let audioInputNode = audioEngine.inputNode
        let recordingFormat = audioInputNode.outputFormat(forBus: 0)
        let fileURL = getAudioFileURL()
        
        do {
            audioFile = try AVAudioFile(forWriting: fileURL, settings: recordingFormat.settings)
        } catch {
            print("Failed to create audio file: \(error.localizedDescription)")
            return nil
        }
        
        audioInputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] (buffer, time) in
            guard let strongSelf = self else { return }
            do {
                if let audioFile = strongSelf.audioFile {
                    try audioFile.write(from: buffer)
                }
            } catch {
                print("Failed to write buffer: \(error.localizedDescription)")
            }
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
            print("Recording started.")
            return fileURL  // Return the file URL for later use
        } catch {
            print("Failed to start audio engine: \(error.localizedDescription)")
            return nil
        }
    }
    
    
    func startRecording() -> URL? {
        // Check microphone permission before starting recording
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            print("Microphone permission granted. Starting recording.")
            return startAudioRecordingProcess()
            
        case .denied:
            print("Microphone permission denied. Cannot start recording.")
            showPermissionDeniedAlert()
            return nil
            
        case .undetermined:
            print("Microphone permission undetermined. Requesting permission.")
            AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        print("Microphone permission granted after request. Starting recording.")
                        _ = self?.startAudioRecordingProcess()  
                    } else {
                        print("Microphone permission denied after request.")
                        self?.showPermissionDeniedAlert()
                    }
                }
            }
            return nil
            
        @unknown default:
            fatalError("Unexpected microphone permission state")
        }
    }

    private func startAudioRecordingProcess() -> URL? {
        let audioInputNode = audioEngine.inputNode
        let recordingFormat = audioInputNode.outputFormat(forBus: 0)
        let fileURL = getAudioFileURL()
        
        do {
            audioFile = try AVAudioFile(forWriting: fileURL, settings: recordingFormat.settings)
        } catch {
            print("Failed to create audio file: \(error.localizedDescription)")
            return nil
        }
        
        audioInputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] (buffer, time) in
            guard let strongSelf = self else { return }
            do {
                if let audioFile = strongSelf.audioFile {
                    try audioFile.write(from: buffer)
                }
            } catch {
                print("Failed to write buffer: \(error.localizedDescription)")
            }
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
            print("Recording started.")
            return fileURL  // Return the file URL for later use
        } catch {
            print("Failed to start audio engine: \(error.localizedDescription)")
            return nil
        }
    }

    
    


    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        print("Recording stopped.")
    }

    // Play audio from file
    func playAudio(fileURL: URL) {
        if FileManager.default.fileExists(atPath: fileURL.path) {
            print("Attempting to play audio from URL: \(fileURL)")
            do {
                // Reset audio engine before playback
                audioEngine.stop()
                audioEngine.reset()
                
                // Create a new AVAudioEngine instance
                audioEngine = AVAudioEngine()
                audioPlayerNode = AVAudioPlayerNode()
                
                // Configure audio session for playback
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
                
                // Set up audio file
                audioFile = try AVAudioFile(forReading: fileURL)
                let audioFormat = audioFile!.processingFormat
                
                // Attach and connect the audio player node
                audioEngine.attach(audioPlayerNode)
                audioEngine.connect(audioPlayerNode, to: audioEngine.mainMixerNode, format: audioFormat)
                
                // Start the engine and schedule playback
                audioEngine.prepare()
                try audioEngine.start()
                audioPlayerNode.scheduleFile(audioFile!, at: nil, completionHandler: {
                    DispatchQueue.main.async {
                        print("Audio playback completed.")
                    }
                })
                
                audioPlayerNode.play()
                print("Playing audio.")
            } catch {
                print("Failed to play audio: \(error.localizedDescription)")
            }
        } else {
            print("File does not exist at path: \(fileURL.path)")
        }
    }
    
    // Handle microphone permission and recording
    private func checkMicrophonePermission() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            print("Microphone permission already granted.")
        case .denied:
            print("Microphone permission denied.")
            showPermissionDeniedAlert()
        case .undetermined:
            requestMicrophonePermission()
        @unknown default:
            fatalError("Unexpected microphone permission state")
        }
    }
    
    private func requestMicrophonePermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                if granted {
                    print("Microphone permission granted after request.")
                } else {
                    print("Microphone permission denied after request.")
                    self?.showPermissionDeniedAlert()
                }
            }
        }
    }
    
    func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    
    private func showPermissionDeniedAlert() {
        guard let topController = UIApplication.shared.windows.first?.rootViewController else { return }
        
        let alert = UIAlertController(title: "Microphone Access Denied",
                                      message: "Please enable microphone access in Settings to record audio.",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings)
            }
        })
        
        topController.present(alert, animated: true, completion: nil)
    }
}
