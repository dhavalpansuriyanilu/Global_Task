//
//  ViewController.swift
//  CameraAppDemo
//
//  Created by MacBook_Air_41 on 23/09/24.
//

import UIKit
import AVFoundation
import Photos
import AVKit

class ViewController: UIViewController, AVCapturePhotoCaptureDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    //https://uvolchyk.medium.com/scrolling-pickers-in-swiftui-de4a9c653fb6
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var imgCamera: UIImageView!
    
    @IBOutlet weak var btnVideo: UIButton!
    @IBOutlet weak var btnPhoto: UIButton!
    @IBOutlet weak var imgLiveTimer: UIImageView!
    @IBOutlet weak var lblTimer: UILabel!
    
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var photoOutput: AVCapturePhotoOutput!
    var currentCamera: AVCaptureDevice?
    var isUsingFrontCamera = false
    
    var videoOutput: AVCaptureMovieFileOutput?
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var flashMode: AVCaptureDevice.FlashMode = .off
    
    // UI buttons
    var captureButton: UIButton!
    var switchCameraButton: UIButton!
    var flashButton: UIButton!
    var closeButton: UIButton!
    var galleryButton: UIButton!
    var livePhotoButton: UIButton!
    
    
    let imagePicker = UIImagePickerController()
    var livePhotoCaptureSupported = false
    var livePhotoCaptureEnabled = false
    var movieOutput = AVCaptureMovieFileOutput() // For recording video
    
    var livePhoto: PHLivePhoto?
    var livePhotoMovieFileURL: URL?
    var isRecording = false
    
    var timer: Timer?
       var elapsedTime: TimeInterval = 0 {
           didSet {
               lblTimer.text = formattedTime(elapsedTime)
           }
       }
    
    enum CaptureMode {
           case photo
           case livePhoto
           case video
       }
       
    var currentCaptureMode: CaptureMode = .photo
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkCameraPermissionsAndOpen(isForPhotoCapture: true)
        setUpUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkCameraPermissionsAndOpen(isForPhotoCapture: false)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionWasInterrupted(_:)), name: .AVCaptureSessionWasInterrupted, object: captureSession)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        stopCaptureSession()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let previewLayer = cameraView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = cameraView.bounds
        }
        
        if let videoPreviewLayer = videoPreviewLayer {
            videoPreviewLayer.frame = cameraView.bounds
            roundCorners(baseview: cameraView, corners: [.bottomLeft, .bottomRight], radius: 50)
        }
    }

    @objc func sessionWasInterrupted(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let reason = userInfo[AVCaptureSessionInterruptionReasonKey] as? AVAudioSession.InterruptionReason
            print("Session was interrupted: \(reason?.rawValue ?? 0)")
        }
    }

    func setUpUI() {
        lblTimer.isHidden = false
        imgLiveTimer.isHidden = false
    }
    
    func checkCameraPermissionsAndOpen(isForPhotoCapture: Bool) {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthorizationStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.setupCameraSession(isForPhotoCapture: isForPhotoCapture)
                    }
                }
            }
        case .authorized:
            setupCameraSession(isForPhotoCapture: isForPhotoCapture)
        case .restricted, .denied:
            showAlertForCameraAccess()
        @unknown default:
            break
        }
    }

    func addAudioInput() {
        guard let microphone = AVCaptureDevice.default(for: .audio) else {
            print("No microphone available")
            return
        }

        do {
            let micInput = try AVCaptureDeviceInput(device: microphone)
            if captureSession.canAddInput(micInput) {
                captureSession.addInput(micInput)
            } else {
                print("Could not add audio input")
            }
        } catch {
            print("Error setting up audio input: \(error)")
        }
    }

    
    // Function to set up camera control buttons within the cameraView
    func setupCameraControls() {
        // Capture button
        captureButton = UIButton(frame: CGRect(x: (cameraView.frame.width - 100) / 2, y: cameraView.frame.height - 280, width: 70, height: 70))
        captureButton.tintColor = .white
        captureButton.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        captureButton.layer.cornerRadius = captureButton.frame.width / 2
        captureButton.addTarget(self, action: #selector(capture), for: .touchUpInside)
        cameraView.addSubview(captureButton)
        
        // Switch camera button
        switchCameraButton = UIButton(frame: CGRect(x: ((cameraView.frame.width - 100) / 2) + 70, y: cameraView.frame.height - 265, width: 65, height: 65))
        switchCameraButton.tintColor = .white
        switchCameraButton.setImage(UIImage(systemName: "camera.rotate"), for: .normal)
        switchCameraButton.addTarget(self, action: #selector(switchCamera), for: .touchUpInside)
        cameraView.addSubview(switchCameraButton)
        
        // Flash button
        flashButton = UIButton(frame: CGRect(x: 300, y: 40, width: 65, height: 65))
        flashButton.tintColor = .white
        flashButton.setImage(UIImage(systemName: "bolt.slash"), for: .normal)
        flashButton.addTarget(self, action: #selector(toggleFlash), for: .touchUpInside)
        cameraView.addSubview(flashButton)
        
        // Close button
        closeButton = UIButton(frame: CGRect(x: 20, y: 40, width: 50, height: 50))
        closeButton.tintColor = .white
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeCamera), for: .touchUpInside)
        cameraView.addSubview(closeButton)
        
        // Gallery button
        galleryButton = UIButton(frame: CGRect(x: 300, y: cameraView.frame.height - 265, width: 65, height: 65))
        galleryButton.tintColor = .white
        galleryButton.setImage(UIImage(systemName: "photo"), for: .normal)
        galleryButton.addTarget(self, action: #selector(openGallery), for: .touchUpInside)
        cameraView.addSubview(galleryButton)
        
        // Live Photo capture button
        livePhotoButton = UIButton(frame: CGRect(x: 300, y: 80, width: 65, height: 65))
        livePhotoButton.tintColor = .white
        livePhotoButton.setImage(UIImage(systemName: "livephoto"), for: .normal)
        livePhotoButton.addTarget(self, action: #selector(updateLiveButton), for: .touchUpInside)
        cameraView.addSubview(livePhotoButton)
        
        // Live video
        btnVideo.addTarget(self, action: #selector(didTapRecordButton), for: .touchUpInside)
    }
    
    
    func setupCameraSession(isForPhotoCapture: Bool) {
        captureSession = AVCaptureSession()
        
        // Set session preset based on capture type
        captureSession.sessionPreset = isForPhotoCapture ? .photo : .high
        
        // Set up the capture device (back or front camera)
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Unable to access camera!")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            
            // Add input to the session
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            } else {
                print("Could not add camera input")
                return
            }
            photoOutput = AVCapturePhotoOutput()
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }
            videoOutput = AVCaptureMovieFileOutput()
            if captureSession.canAddOutput(videoOutput!) {
                captureSession.addOutput(videoOutput!)
            }
//            // Set up photo or video output based on capture type
//            if isForPhotoCapture {
//                // Set up photo output
//                
//                if photoOutput.isLivePhotoCaptureSupported {
//                    photoOutput.isLivePhotoCaptureEnabled = true
//                }
//            } else {
//                // Set up video output
//                
//            }
//            
            // Set up the video preview layer
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer.videoGravity = .resizeAspectFill
            videoPreviewLayer.frame = cameraView.bounds
            cameraView.layer.addSublayer(videoPreviewLayer)
            
            // Start the session
            DispatchQueue.global(qos: .background).async {
                self.captureSession.startRunning()
            }
            
            // Setup buttons and controls within the cameraView
            setupCameraControls()
            
        } catch {
            print("Error setting up camera input: \(error)")
        }
    }

    func startCaptureSession() {
        guard let captureSession = captureSession else { return }
        if !captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                captureSession.startRunning()
            }
        }
    }

    func stopCaptureSession() {
        guard let captureSession = captureSession else { return }

        if captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                captureSession.stopRunning()
            }
        }
    }

    @objc func capture() {
            switch currentCaptureMode {
            case .photo:
                takePhoto()
            case .livePhoto:
                captureLivePhoto()
            case .video:
                didTapRecordButton()
            }
        }

    func takePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        if photoOutput.isLivePhotoCaptureSupported && photoOutput.isLivePhotoCaptureEnabled {
            let livePhotoMovieFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("livePhoto.mov")
            settings.livePhotoMovieFileURL = livePhotoMovieFileURL
        }
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    func captureLivePhoto() {
        guard photoOutput.isLivePhotoCaptureEnabled else {
            print("Live photo capture is not enabled")
            return
        }
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto

        // Set the live photo output URL
        let livePhotoMovieURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString).appendingPathExtension("mov")
        settings.livePhotoMovieFileURL = livePhotoMovieURL

        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    @objc func didTapRecordButton() {
        if isRecording {
            videoOutput?.stopRecording()
            timer?.invalidate()
            elapsedTime = 0
            lblTimer.isHidden = false
            btnVideo.setTitle("Record Video", for: .normal)
            stopCaptureSession()
            navigationController?.popViewController(animated: true)
        } else {
            // Safely create the output path
            let tempDirectory = NSTemporaryDirectory()
            let outputPath = tempDirectory + UUID().uuidString + ".mov"
            let outputURL = URL(fileURLWithPath: outputPath)
            // Check if the videoOutput is initialized
            guard let videoOutput = videoOutput else {
                print("Error: Video output is not initialized.")
                return
            }
            
            videoOutput.startRecording(to: outputURL, recordingDelegate: self)
            btnVideo.setTitle("Stop Recording", for: .normal)
            lblTimer.isHidden = false
            startTimer()
        }
        isRecording.toggle()
    }

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.elapsedTime += 1
            self?.lblTimer.text = self?.formattedTime(self?.elapsedTime ?? 0)
        }
    }
    
    func formattedTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    

    func saveVideoToLibrary(at videoURL: URL) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
        }) { saved, error in
            if saved {
                print("Video saved to Photos Library")
            } else if let error = error {
                print("Error saving video: \(error.localizedDescription)")
            }
        }
    }
    
}


//MARK: -  AVCaptureFileOutputRecordingDelegate - Called when recording starts
extension ViewController : AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print("Started recording to \(fileURL)")
        func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
               if let error = error {
                   print("Error while recording: \(error.localizedDescription)")
               } else {
                   print("Finished recording to: \(outputFileURL)")

                   // The recorded video is saved at outputFileURL, play it using AVPlayerViewController
                   playRecordedVideo(at: outputFileURL)
               }
           }
           
           // Helper method to play the recorded video
           func playRecordedVideo(at url: URL) {
               let player = AVPlayer(url: url)
               let playerViewController = AVPlayerViewController()
               playerViewController.player = player
               
               // Present the AVPlayerViewController
               self.present(playerViewController, animated: true) {
                   playerViewController.player?.play()
               }
           }
    }
    
    // AVCaptureFileOutputRecordingDelegate - Called when recording finishes
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error == nil {
               // Save the video to the Photos Library
               saveVideoToLibrary(at: outputFileURL)
           } else {
               print("Recording failed with error: \(error!.localizedDescription)")
           }
    }
}
  
//MARK: -  AVCapturePhotoCaptureDelegate method to handle the captured image
extension ViewController {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            return
        }
        if let livePhotoMovieFileURL = livePhotoMovieFileURL {
            print("Live Photo Movie File URL: \(livePhotoMovieFileURL)")
        }
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else { return }
        imgCamera.image = image
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.imgCamera.image = nil
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingLivePhotoToMovieFileAt url: URL,
                     duration: CMTime,
                     photoDisplayTime: CMTime,
                     resolvedSettings: AVCaptureResolvedPhotoSettings,
                     error: Error?) {
        if let error = error {
            print("Error processing Live Photo: \(error)")
            return
        }
        print("Live Photo saved at URL: \(url)")
    }
}
    
//MARK: -  UIImagePickerController delegate method to handle the captured image
extension ViewController {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let capturedImage = info[.originalImage] as? UIImage {
            imgCamera.image = capturedImage
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.imgCamera.image = nil
//                self.dismiss(animated: true, completion: nil)
                picker.dismiss(animated: true, completion: nil)
            }
        }
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - Button action
extension ViewController {
    @objc func capturePhoto() {
        if !photoOutput.isLivePhotoCaptureSupported {
            showToast(message: "Live Photo is not supported on this device.")
            return
        }
        let settings = AVCapturePhotoSettings()
        settings.flashMode = flashMode
        
        if livePhotoCaptureEnabled {
            if let codecType = photoOutput.availableLivePhotoVideoCodecTypes.first {
                settings.livePhotoVideoCodecType = codecType
//                settings.livePhotoMovieFileURL = temporaryLivePhotoURL()
                livePhotoMovieFileURL = temporaryLivePhotoURL()
                settings.livePhotoMovieFileURL = livePhotoMovieFileURL
            } else {
                showToast(message: "Live Photo video codec not available.")
                livePhotoCaptureEnabled = false
                return
            }
        } else {
            settings.livePhotoMovieFileURL = nil
        }
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    @objc func switchCamera() {
        captureSession.beginConfiguration()
        if let currentInput = captureSession.inputs.first {
            captureSession.removeInput(currentInput)
        }
        isUsingFrontCamera.toggle()
        let newCamera = isUsingFrontCamera ? AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) : AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        do {
            let input = try AVCaptureDeviceInput(device: newCamera!)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch {
            print("Error switching cameras: \(error)")
        }
        captureSession.commitConfiguration()
    }
    
    @objc func toggleFlash() {
        flashMode = (flashMode == .off) ? .on : .off
        let flashImage = flashMode == .on ? UIImage(systemName: "bolt.fill") : UIImage(systemName: "bolt.slash")
        flashButton.setImage(flashImage, for: .normal)
    }
    
    @objc func closeCamera() {
        
    }
    
    @objc func updateLiveButton() {
        livePhotoCaptureEnabled.toggle()
        showToast(message: livePhotoCaptureEnabled ? "Live is ON" : "Live is OFF")
    }
}

//MARK: - Other functions
extension ViewController {
    func showAlertForCameraAccess() {
        let alert = UIAlertController(title: "Camera Access Needed", message: "Please enable camera access in settings.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Go to Settings", style: .default, handler: { _ in
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func openGallery() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
 
//    @objc func openGallery() {
//        let vc = storyboard?.instantiateViewController(identifier: "LivePhotosViewController") as! LivePhotosViewController
//        
//        let fileManager = FileManager.default
//        let temporaryDirectory = fileManager.temporaryDirectory
//        
//        do {
//            // Get all the URLs in the temporary directory
//            let fileURLs = try fileManager.contentsOfDirectory(at: temporaryDirectory, includingPropertiesForKeys: nil)
//            print("File in the directory: \(fileURLs)")
//            let imageURLs = fileURLs.filter { $0.pathExtension == "jpeg" || $0.pathExtension == "jpg" }
//            let videoURLs = fileURLs.filter { $0.pathExtension == "mov" }
//            if imageURLs.count == videoURLs.count {
//                vc.livePhotoURLs = zip(imageURLs, videoURLs).map { [$0, $1] }
//            } else {
//                print("Error: Mismatched image and video file counts.")
//            }
//        } catch {
//            print("Error loading live photos: \(error.localizedDescription)")
//        }
//        navigationController?.pushViewController(vc, animated: true)
//    }
    
    func showToast(message: String) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width / 2 - 150, y: self.view.frame.size.height - 100, width: 300, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: { (isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    func temporaryLivePhotoURL() -> URL {
        let temporaryDirectory = FileManager.default.temporaryDirectory
        let filename = UUID().uuidString + ".jpeg"
        return temporaryDirectory.appendingPathComponent(filename)
    }
    
}

