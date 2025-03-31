//
//  ViewController.swift
//  AudioRecordDemo
//
//  Created by MacBook_Air_41 on 24/07/24.
//

import UIKit
import AVFoundation
import IQAudioRecorderController


// MARK: - UITableView Cell class
class AudioTableViewCell : UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgPlayPause: UIImageView!
}

class ViewController: UIViewController, IQAudioRecorderViewControllerDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tblAudioList: UITableView!
    @IBOutlet weak var playbackSlider: UISlider!
    @IBOutlet weak var labelCurrentTime: UILabel!
    @IBOutlet weak var labelOverallDuration: UILabel!
    @IBOutlet weak var playButtonOutlet: UIButton!
    
    // MARK: - Other variable
    var audioPlayer: AVAudioPlayer?
    var newAudio: AVAudioFile?
    var audioFiles = [URL(fileURLWithPath: "")]
    let audioRecorderVC = IQAudioRecorderViewController()
    var selectedIndex = -1
    var audioDurations: [Double] = []
    var playbackTimer: Timer?
    var player: AVPlayer?
    var recordingFilePath: String = ""
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAudioSession()
        if let savedPaths = UserDefaults.standard.array(forKey: "savedAudioFiles") as? [String] {
            self.audioFiles = savedPaths.compactMap {
                let components = $0.split(separator: "|")
                if let url = URL(string: String(components[0])) {
                    return url
                }
                return nil
            }
            self.audioDurations = savedPaths.compactMap {
                let components = $0.split(separator: "|")
                return Double(components.last ?? "")
            }
        }
        
        tblAudioList.reloadData()
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    
    // MARK: - Other functions
    @objc func appWillEnterForeground() {
        let savedPaths = self.audioFiles.map { $0.path }
        UserDefaults.standard.set(savedPaths, forKey: "savedAudioFiles")
        UserDefaults.standard.set(savedPaths, forKey: "processedAudioFiles")
        
    }
    
    @objc func appDidEnterBackground() {
        let savedPaths = self.audioFiles.map { $0.path }
        UserDefaults.standard.set(savedPaths, forKey: "savedAudioFiles")
        UserDefaults.standard.set(savedPaths, forKey: "processedAudioFiles")
    }
    
    func stringFromTimeInterval(interval: TimeInterval) -> String {
        let ti = NSInteger(interval)
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        return String(format: "%0.2d:%0.2d", minutes, seconds)
    }
    
    func initAudioPlayer(with url: URL) {
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        // Get overall duration of the audio
        let duration = playerItem.asset.duration
        let seconds = CMTimeGetSeconds(duration)
        //           labelOverallDuration.text = self.stringFromTimeInterval(interval: seconds)
        
        //           playbackSlider.maximumValue = Float(seconds)
        
        player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { [weak self] (CMTime) -> Void in
            guard let self = self else { return }
            if self.player!.currentItem?.status == .readyToPlay {
                let time = CMTimeGetSeconds(self.player!.currentTime())
                //                   self.playbackSlider.value = Float(time)
                //                   self.labelCurrentTime.text = self.stringFromTimeInterval(interval: time)
            }
        }
        NotificationCenter.default.post(name: Notification.Name("audioFileSave"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.finishedPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    
    func initAudioPlayer1(with url: URL) {
        do {
            
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        }catch{
            
        }
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        // Get overall duration of the audio
        let duration = playerItem.asset.duration
        let seconds = CMTimeGetSeconds(duration)
        //        labelOverallDuration.text = self.stringFromTimeInterval(interval: seconds)
        
        // Get the current duration of the audio
        let currentDuration = playerItem.currentTime()
        let currentSeconds = CMTimeGetSeconds(currentDuration)
        //        labelCurrentTime.text = self.stringFromTimeInterval(interval: currentSeconds)
        
        //        playbackSlider.maximumValue = Float(seconds)
        
        player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { [weak self] (CMTime) -> Void in
            guard let self = self else { return }
            if self.player!.currentItem?.status == .readyToPlay {
                let time = CMTimeGetSeconds(self.player!.currentTime())
                //                self.playbackSlider.value = Float(time)
                //                self.labelCurrentTime.text = self.stringFromTimeInterval(interval: time)
            }
            let playbackLikelyToKeepUp = self.player?.currentItem?.isPlaybackLikelyToKeepUp
            if playbackLikelyToKeepUp == false {
                print("IsBuffering")
                //                self.playButtonOutlet.isHidden = true
            } else {
                print("Buffering completed")
                //                playAudio(at: url)
                //                self.playButtonOutlet.isHidden = false
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.finishedPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    @objc func playbackSliderValueChanged(_ playbackSlider: UISlider) {
        let seconds = Int64(playbackSlider.value)
        let targetTime = CMTimeMake(value: seconds, timescale: 1)
        player!.seek(to: targetTime)
        if player!.rate == 0 {
            audioPlayer?.play()
        }
    }
    
    @objc func finishedPlaying(_ myNotification: NSNotification) {
        //        playbackSlider.value = 0
        let targetTime = CMTimeMake(value: 0, timescale: 1)
        player!.seek(to: targetTime)
        selectedIndex = -1
        tblAudioList.reloadData()
    }
    
    func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
        } catch {
            print("Failed to set audio session category and mode: \(error)")
        }
    }
    
    func playAudio(at url: URL) {
        initAudioPlayer(with: url)
        player?.play()
        player?.addObserver(self, forKeyPath: "status", options: [.old, .new], context: nil)
    }
    
    func pauseAudio() {
        audioPlayer?.pause()
        DispatchQueue.main.async {
            self.tblAudioList.reloadData()
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            if let player = object as? AVPlayer {
                switch player.status {
                case .readyToPlay:
                    print("Player is ready to play")
                case .failed:
                    print("Player failed to play: \(String(describing: player.error?.localizedDescription))")
                case .unknown:
                    print("Player status is unknown")
                @unknown default:
                    print("Player status is unknown")
                }
            }
        }
    }
    
    deinit {
        player?.removeObserver(self, forKeyPath: "status")
    }
    
    // MARK: - Button actions
    @IBAction func recordAction(_ sender: UIButton) {
        let controller = IQAudioRecorderViewController()
        controller.delegate = self
        controller.title = "Recorder"
        controller.normalTintColor = .white
        controller.allowCropping = false
        
        // Present the audio recorder view controller
        self.presentBlurredAudioRecorderViewControllerAnimated(controller)
        for item in controller.view.subviews{
            //                if let visualEffectView = item as? UIView {
            let imgLayer = CALayer()
            imgLayer.frame = item.bounds
            imgLayer.contents = UIImage(named: "ic_scary_audio_bg")?.cgImage
            item.layer.insertSublayer(imgLayer, at: 0)
        }
    }
}

// MARK: - IQAudioRecorderViewController delegate
extension ViewController {
    func audioRecorderController(_ controller: IQAudioRecorderViewController, didFinishWithAudioAtPath filePath: String) {
        controller.dismiss(animated: true) {
            saveProcessedAudio(to: self.getOutputURL(name: "sound"), url: URL(fileURLWithPath: filePath))
            saveProcessedAudio1(to: self.getOutputURL(name: "sound1"), url: URL(fileURLWithPath: filePath))
            saveProcessedAudio2(to: self.getOutputURL(name: "sound2"), url: URL(fileURLWithPath: filePath))
            saveProcessedAudio3(to: self.getOutputURL(name: "sound3"), url: URL(fileURLWithPath: filePath))
            saveProcessedAudio4(to: self.getOutputURL(name: "sound4"), url: URL(fileURLWithPath: filePath))
            saveProcessedAudio5(to: self.getOutputURL(name: "sound5"), url: URL(fileURLWithPath: filePath))
            saveProcessedAudio6(to: self.getOutputURL(name: "sound6"), url: URL(fileURLWithPath: filePath))
            saveProcessedAudio7(to: self.getOutputURL(name: "sound7"), url: URL(fileURLWithPath: filePath))
        }
    }
}
// MARK: - UITableViewDelegate UITableViewDataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioFiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AudioTableViewCell") as! AudioTableViewCell
        cell.lblTitle.text = audioFiles[indexPath.row].lastPathComponent
        cell.imgPlayPause.image = UIImage(systemName: "play.fill")
        
        //        print("Configuring cell for \(audioFiles[indexPath.row].lastPathComponent)")
        
        if selectedIndex == indexPath.row {
            cell.imgPlayPause.image = UIImage(systemName: "pause.fill")
        } else {
            cell.imgPlayPause.image = UIImage(systemName: "play.fill")
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NotificationCenter.default.post(name: Notification.Name("audioFileSave"), object: nil)
        if selectedIndex == indexPath.row {
            player?.pause()
            selectedIndex = -1 // Deselect the row
        } else {
            //                self.playAudioFile(url:  audioFiles[indexPath.row].path)
            player?.pause()
            selectedIndex = indexPath.row
            let selectedAudioFile = audioFiles[indexPath.row]
            let audioPlayer = AudioPlayer()
            audioPlayer.playAudioWithReverb(url: selectedAudioFile)
            
            //                playAudio(at: selectedAudioFile)
        }
        tableView.reloadData()
    }
    
    func getOutputURL(name: String) -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "pitched_" + name + ".m4a"
        let outputURL = tempDir.appendingPathComponent(fileName)
        print("Generated output URL: \(outputURL)")
        return outputURL
    }

}


// MARK: - Add Audio effect


import AVFoundation

class AudioPlayer: NSObject {
    var audioEngine: AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var reverb: AVAudioUnitReverb!
    let pitchControl = AVAudioUnitTimePitch()
    
    func playAudioWithReverb(url: URL) {
        //        let audioFileURL = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        audioEngine = AVAudioEngine()
        audioPlayerNode = AVAudioPlayerNode()
        reverb = AVAudioUnitReverb()
        
        audioEngine.attach(audioPlayerNode)
        audioEngine.attach(reverb)
        
        reverb.loadFactoryPreset(.cathedral)
        reverb.wetDryMix = 50
        
        audioEngine.attach(pitchControl)
        
        
        do {
            let audioFile = try AVAudioFile(forReading: url)
            let audioFormat = audioFile.processingFormat
            audioEngine.connect(audioPlayerNode, to: pitchControl, format: audioFormat)
            audioEngine.connect(pitchControl, to: reverb, format: audioFormat)
            audioEngine.connect(reverb, to: audioEngine.mainMixerNode, format: audioFormat)
            
            audioPlayerNode.scheduleFile(audioFile, at: nil, completionHandler: nil)
            try audioEngine.start()
            audioPlayerNode.play()
            let outputFileURL = getDocumentsDirectory().appendingPathComponent("pitchedAudio.m4a")
            let outputFile = try AVAudioFile(forWriting: outputFileURL, settings: audioFile.fileFormat.settings)
            
            //    //        audioEngine.connect(audioPlayerNode, to: reverb, format: nil)
            //            let inputNode = audioEngine.mainMixerNode
            //            let recordingFormat = inputNode.outputFormat(forBus: 0)
            //            if recordingFormat.sampleRate == 0.0 { return }
            
            audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: audioFormat) { buffer, _ in
                do {
                    try outputFile.write(from: buffer)
                } catch {
                    print("Error writing buffer: \(error.localizedDescription)")
                }
            }
            
        } catch {
            print("Failed to play audio with reverb: \(error)")
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

func saveProcessedAudio(to fileURL: URL, url: URL) {
    let audioEngine = AVAudioEngine()
    let audioPlayerNode = AVAudioPlayerNode()
    let reverb = AVAudioUnitReverb()
    let distortion = AVAudioUnitDistortion()
    
    // Setup audio engine
    audioEngine.attach(audioPlayerNode)
    audioEngine.attach(reverb)
    audioEngine.attach(distortion)
    
    // Configure effects
    reverb.loadFactoryPreset(.largeHall)
    reverb.wetDryMix = 50
    
    distortion.loadFactoryPreset(.drumsBitBrush)
    distortion.wetDryMix = 30
    
    // Connect nodes
    audioEngine.connect(audioPlayerNode, to: reverb, format: nil)
    audioEngine.connect(reverb, to: distortion, format: nil)
    audioEngine.connect(distortion, to: audioEngine.mainMixerNode, format: nil)
    
    // Create a file for recording the processed audio
    let format = audioEngine.mainMixerNode.outputFormat(forBus: 0)
    let audioFile = try! AVAudioFile(forWriting: fileURL, settings: format.settings)
    
    // Install a tap to record the output
    audioEngine.mainMixerNode.installTap(onBus: 0, bufferSize: 4096, format: format) { (buffer, time) in
        do {
            try audioFile.write(from: buffer)
        } catch {
            print("Error writing buffer to file: \(error)")
        }
    }
    
    // Load and play your audio file
    //    guard let audioFileURL = Bundle.main.url(forResource: "yourAudioFile", withExtension: "mp3"),
    let audioFile1 = (try? AVAudioFile(forReading: url))!
    //    else {
    //        print("Error loading audio file.")
    //        return
    //    }
    
    audioPlayerNode.scheduleFile(audioFile1, at: nil, completionHandler: nil)
    
    // Start the audio engine and play
    do {
        try audioEngine.start()
        audioPlayerNode.play()
    } catch {
        print("Error starting audio engine: \(error)")
    }
    let asset = AVAsset(url: url)
    let duration = CMTimeGetSeconds(asset.duration)
    
    // Stop and remove the tap after the audio is done
    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
        audioEngine.mainMixerNode.removeTap(onBus: 0)
        audioEngine.stop()
        audioPlayerNode.stop()
    }
}

func saveProcessedAudio1(to fileURL: URL, url: URL) {
    let audioEngine = AVAudioEngine()
    let audioPlayerNode = AVAudioPlayerNode()
    let distortion = AVAudioUnitDistortion()
    let pitch = AVAudioUnitTimePitch()
    let echoNode = AVAudioUnitDistortion()
    let reverbNode = AVAudioUnitReverb()
    let eqNode = AVAudioUnitEQ(numberOfBands: 2)
    let echo = AVAudioUnitDelay()


    
    // Setup audio engine
    audioEngine.attach(audioPlayerNode)
    audioEngine.attach(distortion)
    audioEngine.attach(pitch)
    audioEngine.attach(echoNode)
    audioEngine.attach(reverbNode)
    
    // Configure effects
    distortion.wetDryMix = 50
    distortion.preGain = 3
//    pitch.rate = 1.5
    pitch.pitch = -600
    pitch.rate = 0.75 // 0.8
    
    echoNode.loadFactoryPreset(.multiBrokenSpeaker)
    echoNode.wetDryMix = 50
    
    
    reverbNode.loadFactoryPreset(.largeRoom)
    reverbNode.wetDryMix = 50
    
    distortion.loadFactoryPreset(.speechWaves)
    distortion.wetDryMix = 50
    
    // Configure EQ bands for ghostly effect
       let highEQBand = eqNode.bands[0]
       highEQBand.filterType = .highShelf
       highEQBand.frequency = 2000.0
       highEQBand.bandwidth = 1.0
       highEQBand.gain = -12  // Reduce high frequencies

       let lowEQBand = eqNode.bands[1]
       lowEQBand.filterType = .lowShelf
       lowEQBand.frequency = 200.0
       lowEQBand.bandwidth = 1.0
       lowEQBand.gain = -12  // Reduce low frequencies

       // Enable the EQ bands
       highEQBand.bypass = false
       lowEQBand.bypass = false
    
    
    // Connect nodes
//    audioEngine.connect(audioPlayerNode, to: distortion, format: nil)
//    audioEngine.connect(distortion, to: pitch, format: nil)
//    audioEngine.connect(pitch, to: audioEngine.mainMixerNode, format: nil)
    
    audioEngine.connect(audioPlayerNode, to: pitch, format: nil)
    audioEngine.connect(pitch, to: echoNode, format: nil)
    audioEngine.connect(echoNode, to: reverbNode, format: nil)
    audioEngine.connect(reverbNode, to: distortion, format: nil)
    audioEngine.connect(distortion, to: audioEngine.mainMixerNode, format: nil)
   
    
    // Create a file for recording the processed audio
    let format = audioEngine.mainMixerNode.outputFormat(forBus: 0)
    let audioFile = try! AVAudioFile(forWriting: fileURL, settings: format.settings)
    
    // Install a tap to record the output
    audioEngine.mainMixerNode.installTap(onBus: 0, bufferSize: 4096, format: format) { (buffer, time) in
        do {
            try audioFile.write(from: buffer)
        } catch {
            print("Error writing buffer to file: \(error)")
        }
    }
    
    // Load and play your audio file
    //    guard let audioFileURL = Bundle.main.url(forResource: "yourAudioFile", withExtension: "mp3"),
    let audioFile1 = (try? AVAudioFile(forReading: url))!
    //    else {
    //        print("Error loading audio file.")
    //        return
    //    }
    
    audioPlayerNode.scheduleFile(audioFile1, at: nil, completionHandler: nil)
    
    // Start the audio engine and play
    do {
        try audioEngine.start()
        audioPlayerNode.play()
    } catch {
        print("Error starting audio engine: \(error)")
    }
    let asset = AVAsset(url: url)
    let duration = CMTimeGetSeconds(asset.duration)
    
    // Stop and remove the tap after the audio is done
    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
        audioEngine.mainMixerNode.removeTap(onBus: 0)
        audioEngine.stop()
        audioPlayerNode.stop()
    }
}

//====askdj dkhad kahdkahd kagd adjkashd kskjagsdkga
//====askdj dkhad kahdkahd kagd adjkashd kskjagsdkga
//====askdj dkhad kahdkahd kagd adjkashd kskjagsdkga
//====askdj dkhad kahdkahd kagd adjkashd kskjagsdkga
//====askdj dkhad kahdkahd kagd adjkashd kskjagsdkga
//====askdj dkhad kahdkahd kagd adjkashd kskjagsdkga
//====askdj dkhad kahdkahd kagd adjkashd kskjagsdkga
//Final Sound
func saveProcessedAudio2(to fileURL: URL, url: URL) {
    let audioEngine = AVAudioEngine()
    let audioPlayerNode = AVAudioPlayerNode()
    let delay = AVAudioUnitDelay()
    let pitch = AVAudioUnitTimePitch()
    let echoNode = AVAudioUnitDistortion()
    let reverbNode = AVAudioUnitReverb()
    let distortion = AVAudioUnitDistortion()
    let eqNode = AVAudioUnitEQ(numberOfBands: 2)
    let echo = AVAudioUnitDelay()


    // Setup audio engine
    audioEngine.attach(audioPlayerNode)
    audioEngine.attach(delay)
    audioEngine.attach(pitch)
    audioEngine.attach(echoNode)
    audioEngine.attach(reverbNode)
    audioEngine.attach(distortion)
    audioEngine.attach(eqNode)
    audioEngine.attach(echo)

    // Configure effects
//    delay.delayTime = 0.5
//    delay.wetDryMix = 40
//    pitch.pitch = -1200
    distortion.wetDryMix = 30
    distortion.preGain = 3
//    pitch.rate = 1.5
    pitch.pitch = -600
    pitch.rate = 0.8
    
    echoNode.loadFactoryPreset(.drumsBufferBeats)
    echoNode.wetDryMix = 60
    
    echo.delayTime = 0.5
    
    reverbNode.loadFactoryPreset(.largeChamber)
    reverbNode.wetDryMix = 60
    
    distortion.loadFactoryPreset(.multiDecimated4)
    distortion.wetDryMix = 60
    
    // Configure EQ bands for ghostly effect
       let highEQBand = eqNode.bands[0]
       highEQBand.filterType = .highShelf
       highEQBand.frequency = 6000.0
       highEQBand.bandwidth = 1.0
       highEQBand.gain = -12  // Reduce high frequencies

       let lowEQBand = eqNode.bands[1]
       lowEQBand.filterType = .lowShelf
       lowEQBand.frequency = 600.0
       lowEQBand.bandwidth = 1.0
       lowEQBand.gain = -12  // Reduce low frequencies

       // Enable the EQ bands
       highEQBand.bypass = false
       lowEQBand.bypass = false
    
    // Connect nodes
//    audioEngine.connect(audioPlayerNode, to: delay, format: nil)
//    audioEngine.connect(delay, to: pitch, format: nil)
//    audioEngine.connect(pitch, to: audioEngine.mainMixerNode, format: nil)
    
    audioEngine.connect(audioPlayerNode, to: pitch, format: nil)
    audioEngine.connect(pitch, to: echoNode, format: nil)
    audioEngine.connect(echoNode, to: reverbNode, format: nil)
    audioEngine.connect(reverbNode, to: eqNode, format: nil)
    audioEngine.connect(eqNode, to: distortion, format: nil)
    audioEngine.connect(reverbNode, to: echo, format: nil)
    audioEngine.connect(echo, to: audioEngine.mainMixerNode, format: nil)
    audioEngine.connect(distortion, to: audioEngine.mainMixerNode, format: nil)
    

    // Create a file for recording the processed audio
    let format = audioEngine.mainMixerNode.outputFormat(forBus: 0)
    let audioFile = try! AVAudioFile(forWriting: fileURL, settings: format.settings)
    
    // Install a tap to record the output
    audioEngine.mainMixerNode.installTap(onBus: 0, bufferSize: 4096, format: format) { (buffer, time) in
        do {
            try audioFile.write(from: buffer)
        } catch {
            print("Error writing buffer to file: \(error)")
        }
    }
    
    // Load and play your audio file
    //    guard let audioFileURL = Bundle.main.url(forResource: "yourAudioFile", withExtension: "mp3"),
    let audioFile1 = (try? AVAudioFile(forReading: url))!
    //    else {
    //        print("Error loading audio file.")
    //        return
    //    }
    
    audioPlayerNode.scheduleFile(audioFile1, at: nil, completionHandler: nil)
    
    // Start the audio engine and play
    do {
        try audioEngine.start()
        audioPlayerNode.play()
    } catch {
        print("Error starting audio engine: \(error)")
    }
    let asset = AVAsset(url: url)
    let duration = CMTimeGetSeconds(asset.duration)
    
    // Stop and remove the tap after the audio is done
    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
        audioEngine.mainMixerNode.removeTap(onBus: 0)
        audioEngine.stop()
        audioPlayerNode.stop()
    }
}


func saveProcessedAudio3(to fileURL: URL, url: URL) {
//    let audioEngine = AVAudioEngine()
//    let audioPlayerNode = AVAudioPlayerNode()
//    audioEngine.attach(audioPlayerNode)
//
//    let pitchEffect = AVAudioUnitTimePitch()
//    pitchEffect.pitch = -1200
//    pitchEffect.rate = 0.7
//    audioEngine.attach(pitchEffect)
//
//    let reverbEffect = AVAudioUnitReverb()
//    reverbEffect.loadFactoryPreset(.largeHall2)
//    reverbEffect.wetDryMix = 80
//    audioEngine.attach(reverbEffect)
//
//    audioEngine.connect(audioPlayerNode, to: pitchEffect, format: nil)
//    audioEngine.connect(pitchEffect, to: reverbEffect, format: nil)
//    audioEngine.connect(reverbEffect, to: audioEngine.mainMixerNode, format: nil)
    let audioEngine = AVAudioEngine()
    let audioPlayerNode = AVAudioPlayerNode()
    let distortion = AVAudioUnitDistortion()
    let pitch = AVAudioUnitTimePitch()
    let echoNode = AVAudioUnitDistortion()
    let reverbNode = AVAudioUnitReverb()
    let eqNode = AVAudioUnitEQ(numberOfBands: 2)
    let echo = AVAudioUnitDelay()


    
    // Setup audio engine
    audioEngine.attach(audioPlayerNode)
    audioEngine.attach(distortion)
    audioEngine.attach(pitch)
    audioEngine.attach(echoNode)
    audioEngine.attach(reverbNode)
    audioEngine.attach(eqNode)
    audioEngine.attach(echo)
    
    // Configure effects
    distortion.wetDryMix = 50
    distortion.preGain = 15
//    pitch.rate = 1.5
    pitch.pitch = -1500.0 //-600
    pitch.rate = 0.9 // 0.8
    
    echoNode.loadFactoryPreset(.multiBrokenSpeaker)
    echoNode.wetDryMix = 70
    
    echo.delayTime = 0.5
    
    reverbNode.loadFactoryPreset(.largeRoom)
    reverbNode.wetDryMix = 70
    
    distortion.loadFactoryPreset(.speechWaves)
    distortion.wetDryMix = 70
    
    // Configure EQ bands for ghostly effect
       let highEQBand = eqNode.bands[0]
       highEQBand.filterType = .highShelf
       highEQBand.frequency = 5000.0
       highEQBand.bandwidth = 1.0
       highEQBand.gain = -12  // Reduce high frequencies

       let lowEQBand = eqNode.bands[1]
       lowEQBand.filterType = .lowShelf
       lowEQBand.frequency = 500.0
       lowEQBand.bandwidth = 1.0
       lowEQBand.gain = -12  // Reduce low frequencies

       // Enable the EQ bands
       highEQBand.bypass = false
       lowEQBand.bypass = false
    
    audioEngine.connect(audioPlayerNode, to: pitch, format: nil)
    audioEngine.connect(pitch, to: echoNode, format: nil)
    audioEngine.connect(echoNode, to: reverbNode, format: nil)
    audioEngine.connect(reverbNode, to: eqNode, format: nil)
    audioEngine.connect(eqNode, to: distortion, format: nil)
    audioEngine.connect(reverbNode, to: echo, format: nil)
    audioEngine.connect(echo, to: audioEngine.mainMixerNode, format: nil)
    audioEngine.connect(distortion, to: audioEngine.mainMixerNode, format: nil)
    

    // Create a file for recording the processed audio
    let format = audioEngine.mainMixerNode.outputFormat(forBus: 0)
    let audioFile = try! AVAudioFile(forWriting: fileURL, settings: format.settings)
    
    // Install a tap to record the output
    audioEngine.mainMixerNode.installTap(onBus: 0, bufferSize: 4096, format: format) { (buffer, time) in
        do {
            try audioFile.write(from: buffer)
        } catch {
            print("Error writing buffer to file: \(error)")
        }
    }
    
    // Load and play your audio file
    //    guard let audioFileURL = Bundle.main.url(forResource: "yourAudioFile", withExtension: "mp3"),
    let audioFile1 = (try? AVAudioFile(forReading: url))!
    //    else {
    //        print("Error loading audio file.")
    //        return
    //    }
    
    audioPlayerNode.scheduleFile(audioFile1, at: nil, completionHandler: nil)
    
    // Start the audio engine and play
    do {
        try audioEngine.start()
        audioPlayerNode.play()
    } catch {
        print("Error starting audio engine: \(error)")
    }
    let asset = AVAsset(url: url)
    let duration = CMTimeGetSeconds(asset.duration)
    
    // Stop and remove the tap after the audio is done
    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
        audioEngine.mainMixerNode.removeTap(onBus: 0)
        audioEngine.stop()
        audioPlayerNode.stop()
    }
}

func saveProcessedAudio4(to fileURL: URL, url: URL) {
//    let audioEngine = AVAudioEngine()
//    let audioPlayerNode = AVAudioPlayerNode()
//    audioEngine.attach(audioPlayerNode)
//
//    let pitchEffect = AVAudioUnitTimePitch()
//    pitchEffect.pitch = 1200
//    pitchEffect.rate = 1.5
//
//    let reverbEffect = AVAudioUnitReverb()
//    reverbEffect.loadFactoryPreset(.cathedral)
//    reverbEffect.wetDryMix = 60
//
//    audioEngine.attach(pitchEffect)
//    audioEngine.attach(reverbEffect)
//
//    audioEngine.connect(audioPlayerNode, to: pitchEffect, format: nil)
//    audioEngine.connect(pitchEffect, to: reverbEffect, format: nil)
//    audioEngine.connect(reverbEffect, to: audioEngine.mainMixerNode, format: nil)
    let audioEngine = AVAudioEngine()
    let audioPlayerNode = AVAudioPlayerNode()
    let distortion = AVAudioUnitDistortion()
    let pitch = AVAudioUnitTimePitch()
    let echoNode = AVAudioUnitDistortion()
    let reverbNode = AVAudioUnitReverb()
    let eqNode = AVAudioUnitEQ(numberOfBands: 2)
    let echo = AVAudioUnitDelay()

    
    // Setup audio engine
    audioEngine.attach(audioPlayerNode)
    audioEngine.attach(distortion)
    audioEngine.attach(pitch)
    audioEngine.attach(echoNode)
    audioEngine.attach(reverbNode)
    audioEngine.attach(eqNode)
    audioEngine.attach(echo)
    
    // Configure effects
    distortion.wetDryMix = 50
    distortion.preGain = 15
//    pitch.rate = 1.5
    pitch.pitch = 1500.0 //-600
    pitch.rate = 0.5 // 0.8
    
    echoNode.loadFactoryPreset(.multiBrokenSpeaker)
    echoNode.wetDryMix = 100
    echo.delayTime = 0.5
    
    reverbNode.loadFactoryPreset(.largeRoom)
    reverbNode.wetDryMix = 100
    
    distortion.loadFactoryPreset(.speechWaves)
    distortion.wetDryMix = 100
    
    // Configure EQ bands for ghostly effect
       let highEQBand = eqNode.bands[0]
       highEQBand.filterType = .highShelf
       highEQBand.frequency = 4000.0
       highEQBand.bandwidth = 1.0
       highEQBand.gain = -12  // Reduce high frequencies

       let lowEQBand = eqNode.bands[1]
       lowEQBand.filterType = .lowShelf
       lowEQBand.frequency = 400.0
       lowEQBand.bandwidth = 1.0
       lowEQBand.gain = -12  // Reduce low frequencies

       // Enable the EQ bands
       highEQBand.bypass = false
       lowEQBand.bypass = false
    
    audioEngine.connect(audioPlayerNode, to: pitch, format: nil)
    audioEngine.connect(pitch, to: echoNode, format: nil)
    audioEngine.connect(echoNode, to: reverbNode, format: nil)
    audioEngine.connect(reverbNode, to: eqNode, format: nil)
    audioEngine.connect(eqNode, to: distortion, format: nil)
    audioEngine.connect(reverbNode, to: echo, format: nil)
    audioEngine.connect(echo, to: audioEngine.mainMixerNode, format: nil)
    audioEngine.connect(distortion, to: audioEngine.mainMixerNode, format: nil)
    
    

    // Create a file for recording the processed audio
    let format = audioEngine.mainMixerNode.outputFormat(forBus: 0)
    let audioFile = try! AVAudioFile(forWriting: fileURL, settings: format.settings)
    
    // Install a tap to record the output
    audioEngine.mainMixerNode.installTap(onBus: 0, bufferSize: 4096, format: format) { (buffer, time) in
        do {
            try audioFile.write(from: buffer)
        } catch {
            print("Error writing buffer to file: \(error)")
        }
    }
    
    // Load and play your audio file
    //    guard let audioFileURL = Bundle.main.url(forResource: "yourAudioFile", withExtension: "mp3"),
    let audioFile1 = (try? AVAudioFile(forReading: url))!
    //    else {
    //        print("Error loading audio file.")
    //        return
    //    }
    
    audioPlayerNode.scheduleFile(audioFile1, at: nil, completionHandler: nil)
    
    // Start the audio engine and play
    do {
        try audioEngine.start()
        audioPlayerNode.play()
    } catch {
        print("Error starting audio engine: \(error)")
    }
    let asset = AVAsset(url: url)
    let duration = CMTimeGetSeconds(asset.duration)
    
    // Stop and remove the tap after the audio is done
    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
        audioEngine.mainMixerNode.removeTap(onBus: 0)
        audioEngine.stop()
        audioPlayerNode.stop()
    }
}


func saveProcessedAudio5(to fileURL: URL, url: URL) {
//    let audioEngine = AVAudioEngine()
//    let audioPlayerNode = AVAudioPlayerNode()
//    audioEngine.attach(audioPlayerNode)
//
//    let echoEffect = AVAudioUnitDelay()
//    echoEffect.delayTime = 0.3
//    echoEffect.feedback = 50
//    echoEffect.wetDryMix = 70
//
//    audioEngine.attach(echoEffect)
//
//    audioEngine.connect(audioPlayerNode, to: echoEffect, format: nil)
//    audioEngine.connect(echoEffect, to: audioEngine.mainMixerNode, format: nil)
    
    let audioEngine = AVAudioEngine()
    let audioPlayerNode = AVAudioPlayerNode()
    let distortion = AVAudioUnitDistortion()
    let pitch = AVAudioUnitTimePitch()
    let echoNode = AVAudioUnitDistortion()
    let reverbNode = AVAudioUnitReverb()
    let eqNode = AVAudioUnitEQ(numberOfBands: 2)
    let echo = AVAudioUnitDelay()

    
    // Setup audio engine
    audioEngine.attach(audioPlayerNode)
    audioEngine.attach(distortion)
    audioEngine.attach(pitch)
    audioEngine.attach(echoNode)
    audioEngine.attach(reverbNode)
    audioEngine.attach(eqNode)
    audioEngine.attach(echo)

    
    // Configure effects
    distortion.wetDryMix = 50
    distortion.preGain = 15
//    pitch.rate = 1.5
    pitch.pitch = 2000.0 //-600
    pitch.rate = 0.3 // 0.8
    
    echoNode.loadFactoryPreset(.multiBrokenSpeaker)
    echoNode.wetDryMix = 80
    echo.delayTime = 0.5
    
    reverbNode.loadFactoryPreset(.largeChamber)
    reverbNode.wetDryMix = 80
    
    distortion.loadFactoryPreset(.drumsBufferBeats)
    distortion.wetDryMix = 80
    
    // Configure EQ bands for ghostly effect
       let highEQBand = eqNode.bands[0]
       highEQBand.filterType = .highShelf
       highEQBand.frequency = 3000.0
       highEQBand.bandwidth = 1.0
       highEQBand.gain = -12  // Reduce high frequencies

       let lowEQBand = eqNode.bands[1]
       lowEQBand.filterType = .lowShelf
       lowEQBand.frequency = 300.0
       lowEQBand.bandwidth = 1.0
       lowEQBand.gain = -12  // Reduce low frequencies

       // Enable the EQ bands
       highEQBand.bypass = false
       lowEQBand.bypass = false
    
    audioEngine.connect(audioPlayerNode, to: pitch, format: nil)
    audioEngine.connect(pitch, to: echoNode, format: nil)
    audioEngine.connect(echoNode, to: reverbNode, format: nil)
    audioEngine.connect(reverbNode, to: eqNode, format: nil)
    audioEngine.connect(eqNode, to: distortion, format: nil)
    audioEngine.connect(reverbNode, to: echo, format: nil)
    audioEngine.connect(echo, to: audioEngine.mainMixerNode, format: nil)
    audioEngine.connect(distortion, to: audioEngine.mainMixerNode, format: nil)
    
    

    // Create a file for recording the processed audio
    let format = audioEngine.mainMixerNode.outputFormat(forBus: 0)
    let audioFile = try! AVAudioFile(forWriting: fileURL, settings: format.settings)
    
    // Install a tap to record the output
    audioEngine.mainMixerNode.installTap(onBus: 0, bufferSize: 4096, format: format) { (buffer, time) in
        do {
            try audioFile.write(from: buffer)
        } catch {
            print("Error writing buffer to file: \(error)")
        }
    }
    
    // Load and play your audio file
    //    guard let audioFileURL = Bundle.main.url(forResource: "yourAudioFile", withExtension: "mp3"),
    let audioFile1 = (try? AVAudioFile(forReading: url))!
    //    else {
    //        print("Error loading audio file.")
    //        return
    //    }
    
    audioPlayerNode.scheduleFile(audioFile1, at: nil, completionHandler: nil)
    
    // Start the audio engine and play
    do {
        try audioEngine.start()
        audioPlayerNode.play()
    } catch {
        print("Error starting audio engine: \(error)")
    }
    let asset = AVAsset(url: url)
    let duration = CMTimeGetSeconds(asset.duration)
    
    // Stop and remove the tap after the audio is done
    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
        audioEngine.mainMixerNode.removeTap(onBus: 0)
        audioEngine.stop()
        audioPlayerNode.stop()
    }
}

func saveProcessedAudio6(to fileURL: URL, url: URL) {
//    let audioEngine = AVAudioEngine()
//    let audioPlayerNode = AVAudioPlayerNode()
//    audioEngine.attach(audioPlayerNode)
//
//    let distortionEffect = AVAudioUnitDistortion()
//    distortionEffect.preGain = -6
//    distortionEffect.wetDryMix = 80
//    distortionEffect.loadFactoryPreset(.multiBrokenSpeaker)
//
//    audioEngine.attach(distortionEffect)
//
//    audioEngine.connect(audioPlayerNode, to: distortionEffect, format: nil)
//    audioEngine.connect(distortionEffect, to: audioEngine.mainMixerNode, format: nil)
    let audioEngine = AVAudioEngine()
    let audioPlayerNode = AVAudioPlayerNode()
    let distortion = AVAudioUnitDistortion()
    let pitch = AVAudioUnitTimePitch()
    let echoNode = AVAudioUnitDistortion()
    let reverbNode = AVAudioUnitReverb()
    let eqNode = AVAudioUnitEQ(numberOfBands: 2)
    let echo = AVAudioUnitDelay()

    
    // Setup audio engine
    audioEngine.attach(audioPlayerNode)
    audioEngine.attach(distortion)
    audioEngine.attach(pitch)
    audioEngine.attach(echoNode)
    audioEngine.attach(reverbNode)
    audioEngine.attach(eqNode)
    audioEngine.attach(echo)

    // Configure effects
    distortion.wetDryMix = 90
    distortion.preGain = -5
//    pitch.rate = 1.5
    pitch.pitch = 5000.0 //-600
    pitch.rate = 0.4 // 0.8
    
    echoNode.loadFactoryPreset(.multiDistortedSquared)
    echoNode.wetDryMix = 90
    echo.delayTime = 0.5
    
    reverbNode.loadFactoryPreset(.largeHall)
    reverbNode.wetDryMix = 90
    
    distortion.loadFactoryPreset(.multiEcho2)
    distortion.wetDryMix = 90
    
    // Configure EQ bands for ghostly effect
       let highEQBand = eqNode.bands[0]
       highEQBand.filterType = .highShelf
       highEQBand.frequency = 2000.0
       highEQBand.bandwidth = 1.0
       highEQBand.gain = -12  // Reduce high frequencies

       let lowEQBand = eqNode.bands[1]
       lowEQBand.filterType = .lowShelf
       lowEQBand.frequency = 200.0
       lowEQBand.bandwidth = 1.0
       lowEQBand.gain = -12  // Reduce low frequencies

       // Enable the EQ bands
       highEQBand.bypass = false
       lowEQBand.bypass = false
    
    audioEngine.connect(audioPlayerNode, to: pitch, format: nil)
    audioEngine.connect(pitch, to: echoNode, format: nil)
    audioEngine.connect(echoNode, to: reverbNode, format: nil)
    audioEngine.connect(reverbNode, to: eqNode, format: nil)
    audioEngine.connect(eqNode, to: distortion, format: nil)
    audioEngine.connect(reverbNode, to: echo, format: nil)
    audioEngine.connect(echo, to: audioEngine.mainMixerNode, format: nil)
    audioEngine.connect(distortion, to: audioEngine.mainMixerNode, format: nil)
    
    

    // Create a file for recording the processed audio
    let format = audioEngine.mainMixerNode.outputFormat(forBus: 0)
    let audioFile = try! AVAudioFile(forWriting: fileURL, settings: format.settings)
    
    // Install a tap to record the output
    audioEngine.mainMixerNode.installTap(onBus: 0, bufferSize: 4096, format: format) { (buffer, time) in
        do {
            try audioFile.write(from: buffer)
        } catch {
            print("Error writing buffer to file: \(error)")
        }
    }
    
    // Load and play your audio file
    //    guard let audioFileURL = Bundle.main.url(forResource: "yourAudioFile", withExtension: "mp3"),
    let audioFile1 = (try? AVAudioFile(forReading: url))!
    //    else {
    //        print("Error loading audio file.")
    //        return
    //    }
    
    audioPlayerNode.scheduleFile(audioFile1, at: nil, completionHandler: nil)
    
    // Start the audio engine and play
    do {
        try audioEngine.start()
        audioPlayerNode.play()
    } catch {
        print("Error starting audio engine: \(error)")
    }
    let asset = AVAsset(url: url)
    let duration = CMTimeGetSeconds(asset.duration)
    
    // Stop and remove the tap after the audio is done
    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
        audioEngine.mainMixerNode.removeTap(onBus: 0)
        audioEngine.stop()
        audioPlayerNode.stop()
    }
}

func saveProcessedAudio7(to fileURL: URL, url: URL) {
//    let audioEngine = AVAudioEngine()
//    let audioPlayerNode = AVAudioPlayerNode()
//    audioEngine.attach(audioPlayerNode)
//
//    let reverbEffect = AVAudioUnitReverb()
//    reverbEffect.loadFactoryPreset(.mediumChamber)
//    reverbEffect.wetDryMix = 40
//
//    audioEngine.attach(reverbEffect)
//
//    audioEngine.connect(audioPlayerNode, to: reverbEffect, format: nil)
//    audioEngine.connect(reverbEffect, to: audioEngine.mainMixerNode, format: nil)

    let audioEngine = AVAudioEngine()
    let audioPlayerNode = AVAudioPlayerNode()
    let distortion = AVAudioUnitDistortion()
    let pitch = AVAudioUnitTimePitch()
    let echoNode = AVAudioUnitDistortion()
    let reverbNode = AVAudioUnitReverb()
    let eqNode = AVAudioUnitEQ(numberOfBands: 2)
    let echo = AVAudioUnitDelay()

    
    // Setup audio engine
    audioEngine.attach(audioPlayerNode)
    audioEngine.attach(distortion)
    audioEngine.attach(pitch)
    audioEngine.attach(echoNode)
    audioEngine.attach(reverbNode)
    audioEngine.attach(eqNode)
    audioEngine.attach(echo)

    
    // Configure effects
    distortion.wetDryMix = 30
    distortion.preGain = 5
//    pitch.rate = 1.5
    pitch.pitch = -600
    pitch.rate = 0.8
    
    echoNode.loadFactoryPreset(.multiDistortedCubed)
    echoNode.wetDryMix = 30
    echo.delayTime = 0.5
    
    reverbNode.loadFactoryPreset(.mediumHall3)
    reverbNode.wetDryMix = 30
    
    distortion.loadFactoryPreset(.speechRadioTower)
    distortion.wetDryMix = 30
    
    // Configure EQ bands for ghostly effect
       let highEQBand = eqNode.bands[0]
       highEQBand.filterType = .highShelf
       highEQBand.frequency = 1000.0
       highEQBand.bandwidth = 1.0
       highEQBand.gain = -12  // Reduce high frequencies

       let lowEQBand = eqNode.bands[1]
       lowEQBand.filterType = .lowShelf
       lowEQBand.frequency = 100.0
       lowEQBand.bandwidth = 1.0
       lowEQBand.gain = -12  // Reduce low frequencies

       // Enable the EQ bands
       highEQBand.bypass = false
       lowEQBand.bypass = false
    
    audioEngine.connect(audioPlayerNode, to: pitch, format: nil)
    audioEngine.connect(pitch, to: echoNode, format: nil)
    audioEngine.connect(echoNode, to: reverbNode, format: nil)
    audioEngine.connect(reverbNode, to: eqNode, format: nil)
    audioEngine.connect(eqNode, to: distortion, format: nil)
    audioEngine.connect(reverbNode, to: echo, format: nil)
    audioEngine.connect(echo, to: audioEngine.mainMixerNode, format: nil)
    audioEngine.connect(distortion, to: audioEngine.mainMixerNode, format: nil)
    
    
    // Create a file for recording the processed audio
    let format = audioEngine.mainMixerNode.outputFormat(forBus: 0)
    let audioFile = try! AVAudioFile(forWriting: fileURL, settings: format.settings)
    
    // Install a tap to record the output
    audioEngine.mainMixerNode.installTap(onBus: 0, bufferSize: 4096, format: format) { (buffer, time) in
        do {
            try audioFile.write(from: buffer)
        } catch {
            print("Error writing buffer to file: \(error)")
        }
    }
    
    // Load and play your audio file
    //    guard let audioFileURL = Bundle.main.url(forResource: "yourAudioFile", withExtension: "mp3"),
    let audioFile1 = (try? AVAudioFile(forReading: url))!
    //    else {
    //        print("Error loading audio file.")
    //        return
    //    }
    
    audioPlayerNode.scheduleFile(audioFile1, at: nil, completionHandler: nil)
    
    // Start the audio engine and play
    do {
        try audioEngine.start()
        audioPlayerNode.play()
    } catch {
        print("Error starting audio engine: \(error)")
    }
    let asset = AVAsset(url: url)
    let duration = CMTimeGetSeconds(asset.duration)
    
    // Stop and remove the tap after the audio is done
    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
        audioEngine.mainMixerNode.removeTap(onBus: 0)
        audioEngine.stop()
        audioPlayerNode.stop()
    }
}
