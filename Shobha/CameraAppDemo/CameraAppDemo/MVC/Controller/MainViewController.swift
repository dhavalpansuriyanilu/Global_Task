//
//  MainViewController.swift
//  CameraAppDemo
//
//  Created by MacBook_Air_41 on 25/09/24.
//


import UIKit
import AVFoundation
import Photos

class CameraViewController: UIViewController {
    
    var captureSession: AVCaptureSession!
    var photoOutput: AVCapturePhotoOutput!
    var videoOutput: AVCaptureMovieFileOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var collectionView: UICollectionView!
    
    var capturedImages: [UIImage] = []
    
    let cameraPreviewView = UIView()
    let photoButton = UIButton()
    let videoButton = UIButton()
    let flashButton = UIButton()
    var isStartRecord = false
    let switchCameraButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkPermissions()
        setupCamera()
        setupUI()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Ensure the preview layer is the same size as the cameraPreviewView
        previewLayer.frame = cameraPreviewView.bounds
    }


    func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("No camera available")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
            // Setup photo capture
            photoOutput = AVCapturePhotoOutput()
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }
            //            // Setup video recording
                        videoOutput = AVCaptureMovieFileOutput()
                        if captureSession.canAddOutput(videoOutput) {
                            captureSession.addOutput(videoOutput)
                        }

            // Setup camera preview layer
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.videoGravity = .resizeAspectFill
            cameraPreviewView.layer.addSublayer(previewLayer)
            
            // Start the session after adding the preview layer
            captureSession.startRunning()
            
            // Ensure the preview layer's frame is updated
            previewLayer.frame = cameraPreviewView.bounds
        } catch {
            print("Error setting up camera: \(error)")
        }
    }

    
    // MARK: - Setup Camera
//    func setupCamera() {
//        captureSession = AVCaptureSession()
//        captureSession.sessionPreset = .high
//        
//        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
//            print("No camera available")
//            return
//        }
//        
//        do {
//            let input = try AVCaptureDeviceInput(device: camera)
//            if captureSession.canAddInput(input) {
//                captureSession.addInput(input)
//            }
//            
//            // Setup photo capture
//            photoOutput = AVCapturePhotoOutput()
//            if captureSession.canAddOutput(photoOutput) {
//                captureSession.addOutput(photoOutput)
//            }
//            
//            // Setup video recording
//            videoOutput = AVCaptureMovieFileOutput()
//            if captureSession.canAddOutput(videoOutput) {
//                captureSession.addOutput(videoOutput)
//            }
//            
//            // Setup camera preview layer
//            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//            previewLayer.videoGravity = .resizeAspectFill
//            previewLayer.frame = cameraPreviewView.bounds
//            cameraPreviewView.layer.addSublayer(previewLayer)
//            
//            captureSession.startRunning()
//        } catch {
//            print("Error setting up camera: \(error)")
//        }
//    }
    
    // MARK: - Setup UI Programmatically
    func setupUI() {
        // Setup camera preview view
        cameraPreviewView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height * 0.6)
        view.addSubview(cameraPreviewView)
        
        // Setup buttons
        setupButton(button: photoButton, title: "Photo", color: .systemBlue, selector: #selector(capturePhoto))
        setupButton(button: videoButton, title: "Video", color: .systemRed, selector: #selector(startVideoRecording))
        setupButton(button: flashButton, title: "Flash", color: .systemYellow, selector: #selector(toggleFlash))
        setupButton(button: switchCameraButton, title: "Switch", color: .systemGreen, selector: #selector(switchCamera))
        
        // Arrange buttons in a horizontal stack
        let buttonStack = UIStackView(arrangedSubviews: [photoButton, videoButton, flashButton, switchCameraButton])
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 10
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonStack)
        
        NSLayoutConstraint.activate([
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStack.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Setup collection view for previews
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 80, height: 80)
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: cameraPreviewView.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            collectionView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    func setupButton(button: UIButton, title: String, color: UIColor, selector: Selector) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = color
        button.layer.cornerRadius = 10
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - Permissions
    func checkPermissions() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if !granted {
                print("Camera access denied")
            }
        }
        
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized, .limited:
                break
            case .denied, .restricted:
                print("Photo library access denied")
                break
            default:
                break
            }
        }
    }
    
    // MARK: - Button Actions
    @objc func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        if let device = AVCaptureDevice.default(for: .video), device.hasFlash {
            settings.flashMode = device.isTorchActive ? .on : .off
        }
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    @objc func startVideoRecording() {
        if !isStartRecord{
            isStartRecord = true
            let outputUrl = FileManager.default.temporaryDirectory.appendingPathComponent("video.mov")
            videoOutput.startRecording(to: outputUrl, recordingDelegate: self)
        }else{
            isStartRecord = false
            stopVideoRecording()
        }
    }
    
    @objc func stopVideoRecording() {
        videoOutput.stopRecording()
    }
    
    @objc func toggleFlash() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        try? device.lockForConfiguration()
        device.torchMode = device.torchMode == .on ? .off : .on
        device.unlockForConfiguration()
    }
    
    @objc func switchCamera() {
        captureSession.beginConfiguration()
        if let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput {
            captureSession.removeInput(currentInput)
            let newPosition: AVCaptureDevice.Position = currentInput.device.position == .back ? .front : .back
            if let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition),
               let newInput = try? AVCaptureDeviceInput(device: newDevice) {
                captureSession.addInput(newInput)
            }
        }
        captureSession.commitConfiguration()
    }
}

// MARK: - Photo Capture Delegate
extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) else { return }
        capturedImages.append(image)
        collectionView.reloadData()
    }
}

// MARK: - Video Recording Delegate
extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        // Handle video preview in collection view (you can save video thumbnails)
        print(outputFileURL)
    }
}

// MARK: - CollectionView Delegate and DataSource
extension CameraViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return capturedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let imageView = UIImageView(frame: cell.contentView.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.image = capturedImages[indexPath.row]
        cell.contentView.addSubview(imageView)
        return cell
    }
}
