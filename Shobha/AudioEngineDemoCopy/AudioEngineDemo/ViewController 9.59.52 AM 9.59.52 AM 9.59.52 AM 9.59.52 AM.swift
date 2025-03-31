//
//  ViewController.swift
//  AudioEngineDemo
//
//  Created by MacBook_Air_41 on 10/09/24.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var lblStartStop: UILabel!
    
    var audioEngineHelper: AudioEngineManager!
    var isRecording = false
    var recordedAudioURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        audioEngineHelper = AudioEngineManager.shared
        lblStartStop.text = "Start Recording"
        isRecording = false
        setupAudioSession()
        
        // Check microphone permission on app launch
//        checkMicrophonePermissionOnLaunch()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        recordButton.layer.cornerRadius = recordButton.frame.height / 2
    }
    
    
    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
    
    func checkMicrophonePermissionOnLaunch() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            print("Microphone permission already granted.")
        case .denied:
            print("Microphone permission denied on launch.")
            showPermissionDeniedAlert()
        case .undetermined:
            requestMicrophonePermission()
        @unknown default:
            fatalError("Unexpected microphone permission state")
        }
    }
    
    func requestMicrophonePermission() {
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
    
    func showPermissionDeniedAlert() {
        let alert = UIAlertController(title: "Microphone Access Denied",
                                      message: "Please enable microphone access in Settings to record audio.",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings)
            }
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func recordButtonTapped(_ sender: UIButton) {
        checkMicrophonePermissionAndRecord()
    }
    
    // Play button action
    @IBAction func playButtonTapped(_ sender: UIButton) {
        guard let url = recordedAudioURL else {
            print("No recorded audio file available.")
            return
        }
        audioEngineHelper.playAudio(fileURL: url)
    }
    
    // Handle microphone permission and recording
    func checkMicrophonePermissionAndRecord() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            if isRecording {
                stopRecording()
            } else {
                startRecording()
            }
        case .denied:
            showPermissionDeniedAlert()
        case .undetermined:
            requestMicrophonePermission()
        @unknown default:
            fatalError("Unexpected case for microphone permission")
        }
    }
    
    // Start recording
    func startRecording() {
        recordedAudioURL = audioEngineHelper.startRecording()
        isRecording = true
        lblStartStop.text = "Stop Recording"
        print("Recording started.")
    }
    
    // Stop recording
    func stopRecording() {
        audioEngineHelper.stopRecording()
        isRecording = false
        lblStartStop.text = "Start Recording"
        print("Recording stopped.")
    }
}
 


