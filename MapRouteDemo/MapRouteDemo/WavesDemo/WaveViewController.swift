
import UIKit
import AVFAudio
import UIKit
import AVFAudio

class WaveViewController: UIViewController, AVAudioPlayerDelegate {
    
    @IBOutlet weak var waveFormView: UIView!
    @IBOutlet weak var waveformImageView: UIImageView!
    @IBOutlet weak var playbackWaveformImageView: UIImageView!
    @IBOutlet weak var imgPlayPause: UIImageView!
    @IBOutlet weak var slider: UISlider!

    private let waveformImageDrawer = WaveformImageDrawer()
    
    var recoredUrl: URL?
    var audioPlayer: AVAudioPlayer?
    var timer: Timer?
    var audioDuration = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudioSession()
        setupSlider()
        loadAudio()
    }

    private func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, options: .defaultToSpeaker)
        try? session.setAllowHapticsAndSystemSoundsDuringRecording(true)
        try? session.setActive(true)
    }

    private func setupSlider() {
        slider.minimumValue = 0
        slider.value = 0
        slider.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sliderTapped(_:))))
    }

    private func loadAudio() {
        guard let audioUrl = Bundle.main.url(forResource: "music3", withExtension: "mp3") else { return }
        recoredUrl = audioUrl
        playAudio(from: audioUrl)
    }

    @objc func sliderTapped(_ gesture: UITapGestureRecognizer) {
        let tapLocation = gesture.location(in: slider).x
        let newValue = Float(tapLocation / slider.bounds.width) * slider.maximumValue
        slider.setValue(newValue, animated: true)
        audioPlayer?.currentTime = TimeInterval(newValue)
        updateProgressWaveform(Double(newValue) / audioDuration)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateWaveformImages()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAudio()
    }

    @IBAction func sliderValueChange(_ sender: UISlider) {
        audioPlayer?.currentTime = TimeInterval(sender.value)
        updateProgressWaveform(Double(sender.value) / audioDuration)
    }

    @IBAction func btnPauseTapped(_ sender: UIButton) {
        audioPlayer?.isPlaying == true ? pauseAudio() : playAudio()
    }

    private func playAudio() {
        audioPlayer?.play()
        imgPlayPause.image = UIImage(named: "rec_Pause")
        startTimer()
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

    @objc private func updateTime() {
        guard let player = audioPlayer else { return }
        slider.value = Float(player.currentTime)
        updateProgressWaveform(player.currentTime / audioDuration)
        
        if player.currentTime >= audioDuration {
            stopAudio()
            updateProgressWaveform(1)
        }
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
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

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopAudio()
        updateProgressWaveform(1)
    }

    private func updateProgressWaveform(_ progress: Double) {
        let newWidth = playbackWaveformImageView.bounds.width * CGFloat(progress)
        let maskLayer = CAShapeLayer()
        maskLayer.path = CGPath(rect: CGRect(x: 0, y: 0, width: newWidth, height: playbackWaveformImageView.bounds.height), transform: nil)
        playbackWaveformImageView.layer.mask = maskLayer
    }

    private func updateWaveformImages() {
        guard let url = recoredUrl else { return }
        Task {
            let image = try await waveformImageDrawer.waveformImage(fromAudioAt: url, with: .init(size: waveFormView.bounds.size, style: .striped(.init(color: .lightGray, width: 5, spacing: 3, lineCap: .round)), verticalScalingFactor: 0.35))
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
