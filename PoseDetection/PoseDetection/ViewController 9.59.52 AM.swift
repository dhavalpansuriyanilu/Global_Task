import UIKit
import AVFoundation
import AVKit
import CoreImage

class ViewController: UIViewController, AVCaptureFileOutputRecordingDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: (any Error)?) {
        
    }
    
    
    @IBOutlet weak var viewVideo: UIView!
    
    @IBAction func starRec(_ sender: UIButton){
//        start()
    }
    
    @IBAction func stopRec(_ sender: UIButton){
//        stopRecording()
    }
    
    
    
    var captureSession: AVCaptureSession!
    var videoOutput: AVCaptureMovieFileOutput!
    var playerViewController: AVPlayerViewController!
    var isRecording = false



    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }

    
    // Set up the camera
    func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        guard let camera = AVCaptureDevice.default(for: .video) else { return }
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            captureSession.addInput(input)
        } catch {
            print("Error setting up camera: \(error)")
            return
        }
        
        videoOutput = AVCaptureMovieFileOutput()
        captureSession.addOutput(videoOutput)
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
        
        // Add buttons for recording and playback
        addStartButton()
        addStopButton()
        addPlayButton()
    }
    
    // Add Start Button
    func addStartButton() {
        let startButton = UIButton(frame: CGRect(x: 20, y: view.frame.height - 160, width: 100, height: 50))
        startButton.backgroundColor = .green
        startButton.setTitle("Start", for: .normal)
        startButton.addTarget(self, action: #selector(startRecording), for: .touchUpInside)
        view.addSubview(startButton)
    }
    
    // Add Stop Button
    func addStopButton() {
        let stopButton = UIButton(frame: CGRect(x: 140, y: view.frame.height - 160, width: 100, height: 50))
        stopButton.backgroundColor = .red
        stopButton.setTitle("Stop", for: .normal)
        stopButton.addTarget(self, action: #selector(stopRecording), for: .touchUpInside)
        view.addSubview(stopButton)
    }
    
    // Add Play Button
    func addPlayButton() {
        let playButton = UIButton(frame: CGRect(x: 260, y: view.frame.height - 160, width: 100, height: 50))
        playButton.backgroundColor = .blue
        playButton.setTitle("Play", for: .normal)
        playButton.addTarget(self, action: #selector(playRecordedVideo), for: .touchUpInside)
        view.addSubview(playButton)
    }
    
    // Start Recording
    @objc func startRecording() {
        guard !isRecording else { return }
        
        let filePath = getFilePath()
        let fileURL = URL(fileURLWithPath: filePath)
        videoOutput.startRecording(to: fileURL, recordingDelegate: self)
        isRecording = true
    }
    
    // Stop Recording
    @objc func stopRecording() {
        guard isRecording else { return }
        videoOutput.stopRecording()
        isRecording = false
    }
    
    // Capture output after recording
    func captureOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error != nil {
            print("Error recording video: \(error!.localizedDescription)")
            return
        }
        
        // Apply the red filter to the recorded video
        applyRedFilterToVideo(sourceURL: outputFileURL) { (filteredURL) in
            print("Video with red filter saved at: \(filteredURL.absoluteString)")
        }
    }
    
    // Apply red filter to recorded video
    func applyRedFilterToVideo(sourceURL: URL, completion: @escaping (URL) -> Void) {
        let asset = AVAsset(url: sourceURL)
        
        // Set up video composition
        let composition = AVMutableComposition()
        guard let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else { return }
        
        if let assetVideoTrack = asset.tracks(withMediaType: .video).first {
            do {
                try videoTrack.insertTimeRange(CMTimeRange(start: .zero, duration: asset.duration), of: assetVideoTrack, at: .zero)
            } catch {
                print("Error inserting time range: \(error)")
                return
            }
        }
        
        // Create a video composition to apply the filter
        let layerComposition = AVMutableVideoComposition(asset: composition) { request in
            let sourceImage = request.sourceImage.clampedToExtent()
            
            // Create a red color overlay
            let redColor = CIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.5) // Adjust alpha for opacity
            let redOverlay = CIImage(color: redColor).cropped(to: sourceImage.extent)
            
            let compositedImage = sourceImage.composited(over: redOverlay)
            request.finish(with: compositedImage, context: nil)
        }
        
        layerComposition.frameDuration = CMTime(value: 1, timescale: 30) // Set frame rate
        layerComposition.renderSize = videoTrack.naturalSize
        
        // Export the video with the red filter
        let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)!
        let filteredFilePath = getFilteredFilePath()
        let filteredFileURL = URL(fileURLWithPath: filteredFilePath)
        
        exportSession.videoComposition = layerComposition
        exportSession.outputURL = filteredFileURL
        exportSession.outputFileType = .mp4
        
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                completion(filteredFileURL)
            case .failed:
                print("Export failed: \(exportSession.error?.localizedDescription ?? "Unknown error")")
            case .cancelled:
                print("Export cancelled")
            default:
                break
            }
        }
    }
    
    // Get the file path to store the video
    func getFilePath() -> String {
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let filePath = (documentsDirectory as NSString).appendingPathComponent("video.mp4")
        return filePath
    }
    
    // Get the file path for the filtered video
    func getFilteredFilePath() -> String {
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let filteredFilePath = (documentsDirectory as NSString).appendingPathComponent("filtered_video.mp4")
        return filteredFilePath
    }
    
    // Play the recorded video
    @objc func playRecordedVideo() {
        let filePath = getFilteredFilePath()
        let fileURL = URL(fileURLWithPath: filePath)
        
        let player = AVPlayer(url: fileURL)
        playerViewController = AVPlayerViewController()
        playerViewController.player = player
        present(playerViewController, animated: true) {
            self.playerViewController.player?.play()
        }
    }
}
