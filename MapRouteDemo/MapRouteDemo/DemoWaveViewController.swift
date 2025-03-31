

import UIKit
import AVFAudio
import Foundation


class DemoWaveViewController: UIViewController, AVAudioPlayerDelegate {
    
    @IBOutlet weak var waveContainer: UIView!
    @IBOutlet weak var imgPlayPause: UIImageView!
    
    private let waveObj = LineWaveView()
    private let waveformImageDrawer = WaveformImageDrawer()
    
    var recoredUrl: URL?
    var audioPlayer: AVAudioPlayer?
    var timer: Timer?
    var audioDuration = 0.0
    var slider = UISlider()
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setupUI()
        setupAudioSession()
        loadAudio()
    }
    
    private func setupUI() {
        waveObj.translatesAutoresizingMaskIntoConstraints = false
        waveContainer.addSubview(waveObj)
        slider = waveObj.slider
        
        NSLayoutConstraint.activate([
            waveObj.leadingAnchor.constraint(equalTo: waveContainer.leadingAnchor),
            waveObj.trailingAnchor.constraint(equalTo: waveContainer.trailingAnchor),
            waveObj.topAnchor.constraint(equalTo: waveContainer.topAnchor),
            waveObj.bottomAnchor.constraint(equalTo: waveContainer.bottomAnchor)
        ])
        
        // Enable direct interaction anywhere
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(sliderTapped(_:)))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(sliderDragged(_:)))
        
        slider.addGestureRecognizer(tapGesture)
        slider.addGestureRecognizer(panGesture)
        
        // Slider value change action (dragging)
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
    }

    // Tap anywhere to move the slider
    @objc func sliderTapped(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: slider).x
        let newValue = Float(location / slider.bounds.width) * slider.maximumValue
        slider.setValue(newValue, animated: true)
        updateAudioAndWaveform(for: newValue)
    }

    // Drag anywhere to update the slider smoothly
    @objc func sliderDragged(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: slider).x
        let percentage = min(max(location / slider.bounds.width, 0), 1) // Clamp between 0 and 1
        let newValue = Float(percentage) * slider.maximumValue
        
        slider.setValue(newValue, animated: false)
        
        if gesture.state == .changed || gesture.state == .ended {
            updateAudioAndWaveform(for: newValue)
        }
    }

    // Common function to update audio and waveform
    private func updateAudioAndWaveform(for value: Float) {
        let newTime = TimeInterval(value)
        audioPlayer?.currentTime = newTime
        updateProgressWaveform(newTime / audioDuration)
    }

    // Regular slider drag update
    @objc func sliderValueChanged(_ sender: UISlider) {
        timer?.invalidate() // Pause automatic updates
        updateAudioAndWaveform(for: sender.value)
        startTimer() // Restart timer
    }

    
    @IBAction func btnPauseTapped(_ sender: UIButton) {
        audioPlayer?.isPlaying == true ? pauseAudio() : playAudio()
    }

    private func playAudio() {
        audioPlayer?.play()
        imgPlayPause.image = UIImage(named: "rec_Pause")
        startTimer()
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    @objc private func updateTime() {
        guard let player = audioPlayer else { return }
        slider.value = Float(player.currentTime)
        updateProgressWaveform(player.currentTime / audioDuration)
        
        if player.currentTime >= audioDuration {
            stopAudio()
            updateProgressWaveform(1)
        }
    }
    
    private func pauseAudio() {
        audioPlayer?.pause()
        imgPlayPause.image = UIImage(named: "rec_Play")
        timer?.invalidate()
    }

    private func stopAudio() {
        audioPlayer?.stop()
        imgPlayPause.image = UIImage(named: "rec_Play")
        timer?.invalidate()
    }
    
    private func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, options: .defaultToSpeaker)
        try? session.setAllowHapticsAndSystemSoundsDuringRecording(true)
        try? session.setActive(true)
    }
    
    private func loadAudio() {
        guard let audioUrl = Bundle.main.url(forResource: "music3", withExtension: "mp3") else { return }
        recoredUrl = audioUrl
        playAudio(from: audioUrl)
    }
    
    private func playAudio(from url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioDuration = audioPlayer?.duration ?? 0
            slider.maximumValue = Float(audioDuration)
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateWaveformImages()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopAudio()
        updateProgressWaveform(1)
    }

    private func updateProgressWaveform(_ progress: Double) {
        let newWidth = waveObj.playbackWaveformImageView.bounds.width * CGFloat(progress)
        let maskLayer = CAShapeLayer()
        maskLayer.path = CGPath(rect: CGRect(x: 0, y: 0, width: newWidth, height: waveObj.playbackWaveformImageView.bounds.height), transform: nil)
        waveObj.playbackWaveformImageView.layer.mask = maskLayer
    }

    private func updateWaveformImages() {
        guard let url = recoredUrl else { return }
        Task {
            let image = try await waveformImageDrawer.waveformImage(fromAudioAt: url, with: .init(size: waveObj.bounds.size, style: .striped(.init(color: .lightGray, width: 5, spacing: 3, lineCap: .round)), verticalScalingFactor: 0.35))
            DispatchQueue.main.async {
                self.waveObj.waveformImageTrack.image = image
                self.waveObj.playbackWaveformImageView.image = image.tintedWithLinearGradientColors(
                    colorsArr: [UIColor(hex: "#B53C8C").cgColor,
                                UIColor(hex: "#E94057").cgColor,
                                UIColor(hex: "#F27A36").cgColor],
                    direction: .horizontal
                )
                self.updateProgressWaveform(0)
            }
        }
    }
}


class LineWaveView: UIView {
    
    let waveformImageTrack = UIImageView()
    let playbackWaveformImageView = UIImageView()
    let slider = UISlider()
    
    var audioDuration: Float = 1.0 // Total duration of the audio (set from outside)
    var progressUpdate: ((Float) -> Void)? // Callback to update progress in player
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupActions()
    }
    
    private func setupView() {
        waveformImageTrack.contentMode = .scaleAspectFit
        playbackWaveformImageView.contentMode = .scaleAspectFit
        
        slider.minimumValue = 0
        slider.value = 0
        slider.tintColor = .clear
        slider.thumbTintColor = .clear
        slider.minimumTrackTintColor = .clear
        slider.maximumTrackTintColor = .clear
        
        addSubview(waveformImageTrack)
        addSubview(playbackWaveformImageView)
        addSubview(slider)
        
        waveformImageTrack.translatesAutoresizingMaskIntoConstraints = false
        playbackWaveformImageView.translatesAutoresizingMaskIntoConstraints = false
        slider.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            waveformImageTrack.topAnchor.constraint(equalTo: topAnchor),
            waveformImageTrack.leadingAnchor.constraint(equalTo: leadingAnchor),
            waveformImageTrack.trailingAnchor.constraint(equalTo: trailingAnchor),
            waveformImageTrack.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            playbackWaveformImageView.topAnchor.constraint(equalTo: topAnchor),
            playbackWaveformImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            playbackWaveformImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            playbackWaveformImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            slider.topAnchor.constraint(equalTo: topAnchor),
            slider.leadingAnchor.constraint(equalTo: leadingAnchor),
            slider.trailingAnchor.constraint(equalTo: trailingAnchor),
            slider.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setupActions() {
        // Slider action for dragging
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        
        // Tap gesture for instant seek
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(sliderTapped(_:)))
        slider.addGestureRecognizer(tapGesture)
    }
    
    /// Updates the waveform progress based on the audio playback time
    func updateProgress(_ time: Float) {
        guard time >= 0, time <= audioDuration else { return }
        let progress = time / audioDuration
        slider.value = progress
        playbackWaveformImageView.frame.size.width = CGFloat(progress) * bounds.width
    }
    
    /// Slider dragged to seek the audio
    @objc private func sliderValueChanged(_ sender: UISlider) {
        let newTime = sender.value * audioDuration
        progressUpdate?(newTime) // Notify the player to seek
        updateProgress(newTime)
    }
    
    /// Tap gesture for seeking to a position
    @objc private func sliderTapped(_ gesture: UITapGestureRecognizer) {
        let tapLocation = gesture.location(in: slider)
        let percentage = Float(tapLocation.x / slider.bounds.width)
        let newTime = percentage * audioDuration
        
        slider.setValue(percentage, animated: true)
        progressUpdate?(newTime) // Notify the player to seek
        updateProgress(newTime)
    }
}

/*
 //    private func setupUI() {
 //        waveObj.translatesAutoresizingMaskIntoConstraints = false
 //        waveContainer.addSubview(waveObj)
 //        slider = waveObj.slider
 //
 //        NSLayoutConstraint.activate([
 //            waveObj.leadingAnchor.constraint(equalTo: waveContainer.leadingAnchor),
 //            waveObj.trailingAnchor.constraint(equalTo: waveContainer.trailingAnchor),
 //            waveObj.topAnchor.constraint(equalTo: waveContainer.topAnchor),
 //            waveObj.bottomAnchor.constraint(equalTo: waveContainer.bottomAnchor)
 //        ])
 //
 //        slider.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sliderTapped(_:))))
 //        // Add Slider Value Change Action (for dragging)
 //        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
 //    }
 //
 //    @objc func sliderTapped(_ gesture: UITapGestureRecognizer) {
 //        let tapLocation = gesture.location(in: slider).x
 //        let newValue = Float(tapLocation / slider.bounds.width) * slider.maximumValue
 //        slider.setValue(newValue, animated: true)
 //        audioPlayer?.currentTime = TimeInterval(newValue)
 //        updateProgressWaveform(Double(newValue) / audioDuration)
 //    }
 //
 //    @objc func sliderValueChanged(_ sender: UISlider) {
 //        // Pause automatic timer updates to prevent conflicts
 //        timer?.invalidate()
 //
 //        // Seek audio to the new position
 //        let newTime = TimeInterval(sender.value)
 //        audioPlayer?.currentTime = newTime
 //        updateProgressWaveform(newTime / audioDuration)
 //
 //        // Restart timer to sync UI
 //        startTimer()
 //    }

 */
