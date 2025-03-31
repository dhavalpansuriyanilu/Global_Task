
import UIKit
import AVFoundation
import AVFAudio

class ImageSliderViewController: UIViewController {

   
    @IBOutlet weak var waveView: WaveView!
    @IBOutlet weak var viewCirlce: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWaveView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            
            self.viewCirlce.layer.cornerRadius = self.viewCirlce.frame.height / 2
            self.viewCirlce.addGradientBorder(colors: [
                                                       UIColor(hex:"#F27A36"),
                                                       UIColor(hex:"#E94057"),
                                                       UIColor(hex:"#B53C8C")], lineWidth: 5, gradientDirection: .vertical)

        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        waveView.updateWaveformImages()  // Move it here to ensure proper layout
    }

    private func setupWaveView() {
        view.addSubview(waveView)
        waveView.translatesAutoresizingMaskIntoConstraints = false
        waveView.delegate = self
        
        NSLayoutConstraint.activate([
            waveView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            waveView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            waveView.widthAnchor.constraint(equalToConstant: 300),
            waveView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        if let audioUrl = Bundle.main.url(forResource: "music3", withExtension: "mp3") {
            waveView.loadAudio(from: audioUrl)
            waveView.updateWaveformImages()  // Call after loading audio
        }

    }

    @IBAction func openScreen(_ sender: UIButton) {
        let halfVc = storyboard?.instantiateViewController(identifier: "PresentHalfVC") as! PresentHalfVC
        halfVc.modalPresentationStyle = .overCurrentContext
        self.present(halfVc, animated: true, completion: nil)
    }
    
    @IBAction func playPauseTapped(_ sender: UIButton) {
        if let player = waveView.audioPlayer, player.isPlaying {
            waveView._pause()
            sender.setTitle("Play", for: .normal)
        } else {
            waveView._play()
            sender.setTitle("Pause", for: .normal)
            
        }
    }
}

extension ImageSliderViewController: WaveViewDelegate {
    func waveViewDidFinishPlaying(_ waveView: WaveView) {
        print("Audio finished playing")
    }
}


protocol WaveViewDelegate: AnyObject {
    func waveViewDidFinishPlaying(_ waveView: WaveView)
}

class WaveView: UIView, AVAudioPlayerDelegate {
    
    private let waveformImageView = UIImageView()
    private let playbackWaveformImageView = UIImageView()
    private let slider = UISlider()
    
    private let waveformImageDrawer = WaveformImageDrawer()
    public var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    private var audioDuration: Double = 0.0
    weak var delegate: WaveViewDelegate?
    var recoredUrl: URL?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupSlider()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupSlider()
    }
    
    private func setupUI() {
        addSubview(waveformImageView)
        addSubview(playbackWaveformImageView)
        addSubview(slider)
        
        waveformImageView.translatesAutoresizingMaskIntoConstraints = false
        playbackWaveformImageView.translatesAutoresizingMaskIntoConstraints = false
        slider.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            waveformImageView.topAnchor.constraint(equalTo: topAnchor),
            waveformImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            waveformImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            waveformImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
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
    
    private func setupSlider() {
        slider.minimumValue = 0
        slider.value = 0
        slider.thumbTintColor = .clear
        slider.maximumTrackTintColor = .clear
        slider.minimumTrackTintColor = .clear
        // Enable direct interaction anywhere
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(sliderTapped(_:)))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(sliderDragged(_:)))
        
        slider.addGestureRecognizer(tapGesture)
        slider.addGestureRecognizer(panGesture)
        
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
    }
    
    // Tap anywhere to move the slider
    @objc func sliderTapped(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: slider).x
        let percentage = min(max(location / slider.bounds.width, 0), 1)
        let newValue = Float(percentage) * slider.maximumValue
        
        slider.setValue(newValue, animated: true)
        
        let newTime = TimeInterval(newValue)
        audioPlayer?.currentTime = newTime
       

        if let player = audioPlayer, !player.isPlaying {
            player.play() // Resume playback if it was paused
            updateProgressWaveform(newTime / audioDuration)
            startTimer()
        }
    }


    // Drag anywhere to update the slider smoothly
    @objc func sliderDragged(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: slider).x
        let percentage = min(max(location / slider.bounds.width, 0), 1) // Clamp between 0 and 1
        let newValue = Float(percentage) * slider.maximumValue
        
        slider.setValue(newValue, animated: false)
        
        if gesture.state == .ended { // Only update the audio when dragging ends
            let newTime = TimeInterval(newValue)
            audioPlayer?.currentTime = newTime
            updateProgressWaveform(newTime / audioDuration)
            audioPlayer?.play() // Resume playback if it was paused
            startTimer() // Restart the timer after dragging ends
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
        timer?.invalidate() // Stop auto-updating while dragging
        let newTime = TimeInterval(sender.value)
        audioPlayer?.currentTime = newTime
        updateProgressWaveform(newTime / audioDuration)
    }

    
    public func loadAudio(from url: URL) {
        recoredUrl = url
        playAudio(from: url)
    }
    
    public func playAudio(from url: URL) {
        do {
            recoredUrl = url
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioDuration = audioPlayer?.duration ?? 0
            slider.maximumValue = Float(audioDuration)
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }
    
    public func _play() {
        audioPlayer?.play()
        startTimer()
    }
    
    func _pause() {
        audioPlayer?.pause()
        timer?.invalidate()
    }
    
    func _stop() {
        audioPlayer?.stop()
        timer?.invalidate()
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    @objc private func updateTime() {
        guard let player = audioPlayer else { return }
        if player.currentTime >= audioDuration {
            _stop()
            updateProgressWaveform(1)
        } else {
            slider.value = Float(player.currentTime)
            updateProgressWaveform(player.currentTime / audioDuration)
        }
    }

    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        _stop()
        updateProgressWaveform(1)
    }
    
    private func updateProgressWaveform(_ progress: Double) {
        let newWidth = playbackWaveformImageView.bounds.width * CGFloat(progress)
        let maskLayer = CAShapeLayer()
        maskLayer.path = CGPath(rect: CGRect(x: 0, y: 0, width: newWidth, height: playbackWaveformImageView.bounds.height), transform: nil)
        playbackWaveformImageView.layer.mask = maskLayer
    }

    public func updateWaveformImages() {
        guard let url = recoredUrl else { return }
        Task {
            let image = try await waveformImageDrawer.waveformImage(fromAudioAt: url, with: .init(size: self.bounds.size, style: .striped(.init(color: .lightGray, width: 5, spacing: 3, lineCap: .round)), verticalScalingFactor: 0.35))
            DispatchQueue.main.async {
                self.waveformImageView.image = image
                self.playbackWaveformImageView.image = image.tintedWithLinearGradientColors(
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

