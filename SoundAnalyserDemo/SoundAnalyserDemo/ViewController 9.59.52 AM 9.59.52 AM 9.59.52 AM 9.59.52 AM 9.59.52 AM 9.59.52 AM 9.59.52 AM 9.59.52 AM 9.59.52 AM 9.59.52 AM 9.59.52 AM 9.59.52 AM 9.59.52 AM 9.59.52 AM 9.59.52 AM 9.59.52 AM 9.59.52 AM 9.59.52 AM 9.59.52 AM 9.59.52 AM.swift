//
//  ViewController.swift
//  SoundAnalyserDemo
//
//  Created by MacBook_Air_41 on 20/08/24.
//

import UIKit
import AVKit
import SoundAnalysis


class ViewController: UIViewController {
    
    private let audioEngine = AVAudioEngine()
    private var soundClassifier: DogCatVoiceIdentifier?
    var streamAnalyzer: SNAudioStreamAnalyzer!
    
    @IBOutlet weak var lblResult: UILabel!
    private var isRecording = false


    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Dog Sound Detection"
        
        do {
            let config = MLModelConfiguration()
            soundClassifier = try DogCatVoiceIdentifier(configuration: config)
        } catch {
            print("Failed to initialize sound classifier: \(error.localizedDescription)")
            showAudioError(message: "Sound classifier initialization failed.")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    
    private func startAudioEngine() {
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            showAudioError(message: "Recording is not possible at the moment.")
        }
    }
    
    private func stopRecording() {
        if isRecording {
            audioEngine.inputNode.removeTap(onBus: 0)
            audioEngine.stop()
            isRecording = false
        }
    }
    
    private func prepareForRecording() {
        guard let soundClassifier = soundClassifier else {
            showAudioError(message: "Sound classifier is not available.")
            return
        }
        print("Sound classifier ready: \(soundClassifier)")
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        // Check if inputNode is available
//        if inputNode == nil {
//            showAudioError(message: "Audio input node is not available.")
//            return
//        }
        
        // Create and configure SNAudioStreamAnalyzer
        streamAnalyzer = SNAudioStreamAnalyzer(format: recordingFormat)
        
        // Install tap on input node
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) {
            [unowned self] (buffer, when) in
            DispatchQueue.main.async {
                self.streamAnalyzer.analyze(buffer,
                                            atAudioFramePosition: when.sampleTime)
            }
        }
        
        startAudioEngine()
        isRecording = true
    }


    
    private func createClassificationRequest() {
        guard let soundClassifier = soundClassifier else {
            showAudioError(message: "Sound classifier is not available.")
            return
        }
        
        do {
            let request = try SNClassifySoundRequest(mlModel: soundClassifier.model)
            try streamAnalyzer.add(request, withObserver: self)
        } catch {
            fatalError("Error adding the classification request.")
        }
    }
    
    private func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .default, options: .defaultToSpeaker)
            try audioSession.setActive(true)
        } catch {
            //showAudioError(message: "Failed to configure audio session.")
        }
    }

    
//    @IBAction func startRecordingButtonTapped(_ sender: UIButton) {
//        configureAudioSession()
//        guard soundClassifier != nil else {
//            showAudioError(message: "Sound classification is not supported or failed to initialize.")
//            return
//        }
//        prepareForRecording()
//        createClassificationRequest()
//    }
    
    // Start recording when app enters the background
        @objc func appWillResignActive() {
            stopRecording()
            print("App running in background")
            lblResult.text = "Recording is OFF"
        }
    
    // Start recording when app enters the foreground
       @objc func appWillEnterForeground() {
           configureAudioSession()
           if !isRecording {
               prepareForRecording()
               createClassificationRequest()
           }
           print("App is in foreground, recording started.")
           lblResult.text = "Recording is ON"
       }
    
    @IBAction func startRecordingButtonTapped(_ sender: UIButton) {
           configureAudioSession()
           guard soundClassifier != nil else {
               showAudioError(message: "Sound classification is not supported or failed to initialize.")
               return
           }
           if isRecording {
               stopRecording()
               sender.setTitle("Start Recording", for: .normal)
           } else {
               prepareForRecording()
               createClassificationRequest()
               sender.setTitle("Stop Recording", for: .normal)
           }
       }
    
}

extension ViewController: SNResultsObserving {
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let result = result as? SNClassificationResult else { return }

        // Filter for dog sound results
        if let dogSound = result.classifications.first(where: { $0.identifier.lowercased() == "dog" }) {
            let confidence = dogSound.confidence * 100
            if confidence > 5 {
                DispatchQueue.main.async { [weak self] in
                    // Show dog sound and confidence in lblResult
                    self?.lblResult.text = "Dog Sound Detected with \(Int(confidence))% confidence."
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.lblResult.text = "No dog sound detected."
                }
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.lblResult.text = "No dog sound detected."
            }
        }
    }
}

extension ViewController {
    
    func showAudioError(message: String) {
        let errorTitle = "Audio Error"
        self.showAlert(title: errorTitle, message: message)
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}
