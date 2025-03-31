//
//  NewViewController.swift
//  CameraAppDemo
//
//  Created by MacBook_Air_41 on 25/09/24.
//

import UIKit
import AVFoundation
import Photos

class NewViewController: UIViewController {
    
    var captureSession: AVCaptureSession!
    var photoOutput: AVCapturePhotoOutput!
    var videoOutput: AVCaptureMovieFileOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var capturedImages: [UIImage] = []
    var capturedVideo: [URL] = []
    var isStartRecord = false
    
    @IBOutlet weak var closeButton : UIButton!
    @IBOutlet weak var lblTimer : UILabel!
    @IBOutlet weak var cameraPreviewView : UIView!
    @IBOutlet weak var photoButton : UIButton!
    @IBOutlet weak var videoButton : UIButton!
    @IBOutlet weak var flashButton : UIButton!
    @IBOutlet weak var switchCameraButton : UIButton!
    @IBOutlet weak var galleryButton: UIButton!
    @IBOutlet weak var centerView: UIView!
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var centerButtonView: UIView!
    @IBOutlet weak var centerSeletedView: UIView!
    @IBOutlet weak var imgSelectedOption: UIImageView!
    @IBOutlet weak var innerView2: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imgPlayPause: UIImageView!
    @IBOutlet weak var lblCatName: UILabel!
    @IBOutlet weak var catView: UIView!
    @IBOutlet weak var btnPlayPause: UIButton!
    @IBOutlet weak var timerView: UIView!

    
    
    
    var visibleIndexPath: IndexPath? = nil
    var isVideoButtonSelected = false
    var isPhotoButtonSelected = true
    var selectedIndex = 0
    var duplicatedArray: [UIImage] = []
    var audioPlayer: AVAudioPlayer?
    var currentlyPlayingIndex: Int?

    
    var imgArray: [UIImage] = [
        UIImage(named: "user")!,
        UIImage(named: "user")!,
        UIImage(named: "user")!,
        UIImage(named: "user")!,
        UIImage(named: "user")!,
        UIImage(named: "user")!,
        UIImage(named: "user")!,
        UIImage(named: "user")!,
        UIImage(named: "user")!,
        UIImage(named: "user")!,
    ]
    
    var nameArray : [String] = ["Meow1","Meow2","Meow3","Meow4","Meow5","Meow6","Meow7","Meow8","Meow9","Meow10"]
    var audioArray: [String] = ["dogwhistle", "dogwhistle", "dogwhistle","dogwhistle","dogwhistle","dogwhistle","dogwhistle","dogwhistle","dogwhistle","dogwhistle"]
    var timer: Timer?
    var elapsedTime: TimeInterval = 0 {
        didSet {
            lblTimer.text = formattedTime(elapsedTime)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
        checkPermissions()
        setupCamera()
        setUpUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        switchCameraButton.layer.cornerRadius = switchCameraButton.frame.height / 2
        galleryButton.layer.cornerRadius = galleryButton.frame.height / 2
        centerView.layer.cornerRadius = centerView.frame.height / 2
        innerView.layer.cornerRadius = innerView.frame.height / 2
        centerSeletedView.layer.cornerRadius = centerSeletedView.frame.height / 2
        imgSelectedOption.layer.cornerRadius = imgSelectedOption.frame.height / 2
        innerView2.layer.cornerRadius = innerView2.frame.height / 2
        catView.layer.cornerRadius = catView.frame.height / 2
        previewLayer.frame = cameraPreviewView.bounds
        previewLayer.zPosition = -1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        super.viewWillAppear(animated)
        collectionView.reloadData()
        DispatchQueue.main.async {
            self.applyInitialTransformations()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        capturedImages.removeAll()
        captureSession.stopRunning()
    }
    
    func setUpUI() {
        imgPlayPause.isHidden = true
        self.timerView.isHidden = true
        if isPhotoButtonSelected {
           // btnPlayPause.isUserInteractionEnabled = false
        } else {
           // btnPlayPause.isUserInteractionEnabled = false
        }
    }
    
    private func applyInitialTransformations() {
        let center = collectionView.bounds.midX
        for cell in collectionView.visibleCells {
            if let indexPath = collectionView.indexPath(for: cell) {
                let distanceFromCenter = abs(cell.center.x - center)
                let maxSize = collectionView.bounds.width * 0.8 // Middle cell size
                let scale = max(1 - (distanceFromCenter / (maxSize / 2)), 0.6)
                cell.transform = CGAffineTransform(scaleX: scale, y: scale)
                cell.layer.cornerRadius = cell.frame.height / 2
                cell.layer.masksToBounds = true
            }
        }
    }
    
    private func centerInitialVisibleCell() {
        let totalItems = imgArray.count
        let centerIndex = IndexPath(item: totalItems / 2, section: 0)
        collectionView.scrollToItem(at: centerIndex, at: .centeredVertically, animated: false)
        alignCenterCellToCenterView()
    }
    
    private func alignCenterCellToCenterView() {
        let centerIndex = IndexPath(item: imgArray.count / 2, section: 0)
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let attributes = layout.layoutAttributesForItem(at: centerIndex)
            if let attributes = attributes {
                let centerViewCenter = centerView.center.x
                let itemCenter = attributes.center.x
                let offsetX = itemCenter - centerViewCenter
                collectionView.setContentOffset(CGPoint(x: offsetX, y: collectionView.contentOffset.y), animated: false)
            }
        }
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
            //  Setup video recording
            videoOutput = AVCaptureMovieFileOutput()
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            }
            
            // Setup camera preview layer
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.videoGravity = .resizeAspectFill
            cameraPreviewView.layer.addSublayer(previewLayer)
            
            // Start the session after adding the preview layer
            DispatchQueue.global(qos: .background).async {
                self.captureSession.startRunning()
            }
            // Ensure the preview layer's frame is updated
            previewLayer.frame = cameraPreviewView.bounds
        } catch {
            print("Error setting up camera: \(error)")
        }
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
    
    //MARK: Button Actions
    @IBAction func switchCameraTapped(_ sender: UIButton) {
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
    
    @IBAction func flashButtonTapped(_ sender: UIButton) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        
        do {
            try device.lockForConfiguration()
            // Toggle torch mode
            if device.torchMode == .on {
                device.torchMode = .off
                sender.setImage(UIImage(named: "icn_flashOff"), for: .normal)
            } else {
                try device.setTorchModeOn(level: 1.0)
                sender.setImage(UIImage(named: "icn_flashOn"), for: .normal)
            }
            
            device.unlockForConfiguration()
        } catch {
            print("Torch could not be used: \(error)")
        }
    }
    
    
    @IBAction func galleryButtonTapped(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(identifier: "GalleryViewController") as! GalleryViewController
        vc.capturedImages = self.capturedImages
        vc.capturedVideos = self.capturedVideo
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func videoButtonTapped(_ sender: UIButton) {
        if isPhotoButtonSelected {
            UIView.animate(withDuration: 0.5) {
                self.moveRight(btn: self.videoButton)
                self.videoButton.setTitleColor(.white, for: .normal)
                self.photoButton.setTitleColor(.gray, for: .normal)
            }
           // self.btnPlayPause.isUserInteractionEnabled = true
            innerView.backgroundColor = .red
            centerView.borderColor = .white
            isPhotoButtonSelected = false
            isVideoButtonSelected = true
        }
    }
    
    @IBAction func photoButtonTapped(_ sender: UIButton) {
        timerView.isHidden = true
        if isStartRecord == true {
            timerView.isHidden = false
            let stopAction = UIAlertAction(title: "Stop", style: .default) { [self] _ in
                print("Stop action tapped")
                stopButtonAction()
                movePhotoButton()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                print("Cancel action tapped")
                self.cancelButtonAction()
            }
            showAlert(title: "Confirmation", message: "Are you sure you want to stop recording?", actions: [stopAction, cancelAction])
            
        } else {
            movePhotoButton()
        }
    }
    
    @IBAction func offCameraButtonTapped(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(identifier: "WhistleViewController") as! WhistleViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func stopButtonAction() {
        self.isStartRecord = false
        self.timerView.isHidden = true
        self.stopVideoRecording()
        self.timer?.invalidate()
        self.centerView.borderColor = .orange
        self.innerView.backgroundColor = .orange
       // self.btnPlayPause.isUserInteractionEnabled = false

        // Capture photo logic
        let settings = AVCapturePhotoSettings()
        if let device = AVCaptureDevice.default(for: .video), device.hasFlash {
            settings.flashMode = device.isTorchActive ? .on : .off
        }
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func cancelButtonAction() {
        if isPhotoButtonSelected {
            UIView.animate(withDuration: 0.5) {
                self.moveRight(btn: self.videoButton)
                self.videoButton.setTitleColor(.white, for: .normal)
                self.photoButton.setTitleColor(.gray, for: .normal)
            }
            self.btnPlayPause.isUserInteractionEnabled = true
            isVideoButtonSelected = true
            isPhotoButtonSelected = false
        }
        timerView.isHidden = false
        isStartRecord = true
        imgPlayPause.isHidden = false
        innerView.backgroundColor = .clear
        imgPlayPause.backgroundColor = .red
        imgPlayPause.layer.cornerRadius = 5
        
        let outputUrl = FileManager.default.temporaryDirectory.appendingPathComponent("video.mov")
        videoOutput.startRecording(to: outputUrl, recordingDelegate: self)
        centerView.borderColor = .white
    }
    
    func movePhotoButton() {
        if isVideoButtonSelected {
            UIView.animate(withDuration: 0.5) {
                self.moveLeft(btn: self.photoButton)
                self.videoButton.setTitleColor(.gray, for: .normal)
                self.photoButton.setTitleColor(.white, for: .normal)
            }
            isVideoButtonSelected = false
            isPhotoButtonSelected = true
            innerView.backgroundColor = .orange
            centerView.borderColor = .orange
        }
    }
    
    @IBAction func centerButtonTapped(_ sender: UIButton) {
        guard let indexPath = visibleIndexPath else {
            print("No cell is currently centered.")
            return
        }
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        collectionView(collectionView, didSelectItemAt: indexPath)
    }
    
    @IBAction func playPauseButtonTapped(_ sender: UIButton) {
        
        if isPhotoButtonSelected {
            stopVideoRecording()
            timer?.invalidate()
            timerView.isHidden = true
            let settings = AVCapturePhotoSettings()
            if let device = AVCaptureDevice.default(for: .video), device.hasFlash {
                settings.flashMode = device.isTorchActive ? .on : .off
            }
            photoOutput.capturePhoto(with: settings, delegate: self)
        } else {
            startVideoRecord()
        }
        
//        if !isStartRecord {
//            isStartRecord = true
//            imgPlayPause.isHidden = false
//            innerView.backgroundColor = .clear
//            imgPlayPause.backgroundColor = .red
//            imgPlayPause.layer.cornerRadius = 5
//            let outputUrl = FileManager.default.temporaryDirectory.appendingPathComponent("video.mov")
//            videoOutput.startRecording(to: outputUrl, recordingDelegate: self)
//            startTimer()
//        } else {
//            isStartRecord = false
//            innerView.backgroundColor = .red
//            stopVideoRecording()
//            timer?.invalidate()
//        }
    }
    
    func startVideoRecord() {
        if !isStartRecord {
            self.timerView.isHidden = false
            isStartRecord = true
            timer?.invalidate()
            elapsedTime = 0
            imgPlayPause.isHidden = false
            innerView.backgroundColor = .clear
            imgPlayPause.backgroundColor = .red
            imgPlayPause.layer.cornerRadius = 5
            let outputUrl = FileManager.default.temporaryDirectory.appendingPathComponent("video.mov")
            videoOutput.startRecording(to: outputUrl, recordingDelegate: self)
            startTimer()
        } else {
            isStartRecord = false
            innerView.backgroundColor = .red
            stopVideoRecording()
            timer?.invalidate()
        }
    }
    
    @objc func stopVideoRecording() {
        videoOutput.stopRecording()
        timer?.invalidate()
        timerView.isHidden = true
        imgPlayPause.isHidden = true
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.elapsedTime += 1
            self?.lblTimer.text = self?.formattedTime(self?.elapsedTime ?? 0)
        }
    }
    
    func formattedTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    func moveRight(btn : UIButton) {
        let buttonWidth: CGFloat = btn.frame.width
        let newXPosition = view.frame.width / 2 - buttonWidth / 2
        
        // Move video button to center and photo button to the right
        btn.frame.origin.x = newXPosition
        photoButton.frame.origin.x = newXPosition + buttonWidth + 20
    }
    
    func moveLeft(btn : UIButton) {
        let buttonWidth: CGFloat = btn.frame.width
        let newXPosition = view.frame.width / 2 - buttonWidth / 2
        
        // Move photo button to center and video button to the left
        btn.frame.origin.x = newXPosition
        videoButton.frame.origin.x = newXPosition - buttonWidth - 20
    }
    
    func saveImageToDirectory1(image: UIImage, imageName: String) -> URL? {
        guard let data = image.jpegData(compressionQuality: 1.0) else { return nil }
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsDirectory.appendingPathComponent("\(imageName).jpg")
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
    
    func saveImageToDocumentsDirectory(image: UIImage, withName name: String) -> URL? {
        let fileManager = FileManager.default
        if let data = image.jpegData(compressionQuality: 1.0) {
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsDirectory.appendingPathComponent("\(name).jpg")
            do {
                try data.write(to: fileURL)
//                saveImageURLToUserDefaults(fileURL)
                
                return fileURL
            } catch {
                print("Error saving image: \(error.localizedDescription)")
                return nil
            }
        }
        return nil
    }

    func saveImageURLToUserDefaults(_ fileURL: URL) {
        var savedImageURLs = UserDefaults.standard.array(forKey: "SavedImageURLs") as? [String] ?? []
        savedImageURLs.append(fileURL.path) // Save the file path as a string
        UserDefaults.standard.set(savedImageURLs, forKey: "SavedImageURLs")
    }

    
    func saveImageToUserDefaults(image: UIImage, imageName: String) {
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            var savedImages = UserDefaults.standard.array(forKey: "savedImages") as? [Data] ?? []
            savedImages.append(imageData)
            UserDefaults.standard.set(savedImages, forKey: "savedImages")
        }
    }
    
    func saveVideoToDocumentsDirectory(outputFileURL: URL) {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Could not access documents directory")
            return
        }
        let videoFolderURL = documentsDirectory.appendingPathComponent("Videos")
        do {
            if !fileManager.fileExists(atPath: videoFolderURL.path) {
                try fileManager.createDirectory(at: videoFolderURL, withIntermediateDirectories: true, attributes: nil)
            }
            let videoName = UUID().uuidString + ".mov"
            let destinationURL = videoFolderURL.appendingPathComponent(videoName)
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.moveItem(at: outputFileURL, to: destinationURL)
            var recordedVideoURLs = UserDefaults.standard.array(forKey: "recordedVideoURLs") as? [String] ?? []
            recordedVideoURLs.append(destinationURL.absoluteString)
            UserDefaults.standard.set(recordedVideoURLs, forKey: "recordedVideoURLs")
            capturedVideo.append(destinationURL)
            print("Video successfully saved to documents directory: \(destinationURL)")
        } catch {
            print("Error saving video: \(error.localizedDescription)")
        }
    }

    func saveImageToDocumentsDirectoryNew(image: UIImage, withName name: String) -> URL? {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Could not access documents directory")
            return nil
        }
        let imagesFolderURL = documentsDirectory.appendingPathComponent("Images")
        
        do {
            if !fileManager.fileExists(atPath: imagesFolderURL.path) {
                try fileManager.createDirectory(at: imagesFolderURL, withIntermediateDirectories: true, attributes: nil)
            }
            let imageName = name + ".jpg"
            let destinationURL = imagesFolderURL.appendingPathComponent(imageName)
            if let data = image.jpegData(compressionQuality: 1.0) {
                try data.write(to: destinationURL)
                
                var savedImageURLs = UserDefaults.standard.array(forKey: "savedImageURLs") as? [String] ?? []
                savedImageURLs.append(destinationURL.absoluteString)
                UserDefaults.standard.set(savedImageURLs, forKey: "savedImageURLs")
                
                print("Image successfully saved to documents directory: \(destinationURL)")
                return destinationURL
            } else {
                print("Could not convert image to JPEG data")
                return nil
            }
        } catch {
            print("Error saving image: \(error.localizedDescription)")
            return nil
        }
    }

    
    func playAudio(for index: Int) {
        let audioFileName = audioArray[index]
        guard let url = Bundle.main.url(forResource: audioFileName, withExtension: "wav") else {
            print("Audio file not found.")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }
    
    func stopAudio() {
        audioPlayer?.stop()
        currentlyPlayingIndex = nil
    }
    
    func toggleAudio(for index: Int) {
        if let playingIndex = currentlyPlayingIndex, playingIndex == index {
            stopAudio()
        } else {
            stopAudio()
            playAudio(for: index)
            currentlyPlayingIndex = index
        }
    }
    
    func centerCell(at indexPath: IndexPath) {
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let collectionViewSize = collectionView.bounds.size
        let cellFrame = collectionView.layoutAttributesForItem(at: indexPath)?.frame ?? CGRect.zero
        let offsetX = cellFrame.midX - (collectionViewSize.width / 2)
        let maxOffsetX = collectionView.contentSize.width - collectionViewSize.width
        let targetOffsetX = max(0, min(offsetX, maxOffsetX))
        collectionView.setContentOffset(CGPoint(x: targetOffsetX, y: collectionView.contentOffset.y), animated: true)
    }


}

// MARK: - Photo Capture Delegate
extension NewViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) else { return }
//        capturedImages.append(image)
        
        let imageName = UUID().uuidString
        if let fileURL = saveImageToDocumentsDirectoryNew(image: image, withName: imageName) {
            print("Image saved at: \(fileURL)")
            capturedImages.append(image)
        }
//        saveImageToUserDefaults(image: image, imageName: imageName)
    }

}

// MARK: - Video Recording Delegate
extension NewViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        // Handle video preview in collection view (you can save video thumbnails)
           print("Video saved at: \(outputFileURL)")
        saveVideoToDocumentsDirectory(outputFileURL: outputFileURL)
    }
}

// MARK: - CollectionView Delegate and DataSource
extension NewViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        let imageView = UIImageView(frame: cell.contentView.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.image = imgArray[indexPath.row]
        cell.contentView.addSubview(imageView)
        cell.layer.cornerRadius = cell.frame.height / 2
        cell.contentView.layer.cornerRadius = cell.contentView.frame.height / 2
        cell.layer.masksToBounds = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        selectedIndex = indexPath.item
        lblCatName.text = nameArray[indexPath.item]
        centerCell(at: indexPath)
        toggleAudio(for: selectedIndex)
        print("Selected index: \(selectedIndex)")
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        snapToNearestCell()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            snapToNearestCell()
        }
    }
    
    // Snap the nearest cell to the center after scrolling
    func snapToNearestCell() {
        let centerPoint = view.convert(collectionView.center, to: collectionView)
        
        if let indexPath = collectionView.indexPathForItem(at: centerPoint) {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            selectedIndex = indexPath.row
            self.lblCatName.text = nameArray[selectedIndex]
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let inset = (collectionView.bounds.width - 80) / 2
//        let inset = (collectionView.bounds.width - collectionView.bounds.width * 0.6)
        return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
        
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let center = collectionView.bounds.midX
        for cell in collectionView.visibleCells {
            if let indexPath = collectionView.indexPath(for: cell) {
                // Calculate distance from center
                let distanceFromCenter = abs(cell.center.x - center)
                let maxSize = collectionView.bounds.width * 0.8 // middle cell size
                let scale = max(1 - (distanceFromCenter / (maxSize / 2)), 0.6)
                
                // Apply the transform
                cell.transform = CGAffineTransform(scaleX: scale, y: scale)
                cell.contentView.layer.cornerRadius = cell.contentView.frame.height/2
                cell.layer.cornerRadius = cell.frame.height/2
                
                // Set opacity for non-center cells
                let opacity = max(1 - (distanceFromCenter / (maxSize / 2)), 0.5)
                cell.contentView.alpha = opacity
            }
        }
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        if let indexPath = collectionView.indexPathForItem(at: visiblePoint) {
            visibleIndexPath = indexPath
        }
    }
}
