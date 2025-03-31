import UIKit

class ColorBrightnessVC: UIViewController {
    let audioProcessing = AudioProcessing.shared
    var timer: Timer?
    var data: [Float] = Array(repeating: 0, count: 40)
    var isPlaying: Bool = false
    
    @IBOutlet weak var imgBulb: UIImageView!
    @IBOutlet weak var btnPlayPause: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize button state
        btnPlayPause.setTitle("Play", for: .normal)
        btnPlayPause.setTitle("Pause", for: .selected)
//        audioProcessing.setupAudio()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        // Resume audio if it was playing before
        if isPlaying {
            startAudioProcessing()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause audio only if it's playing when leaving the view controller
        if isPlaying {
            stopAudioProcessing()
            audioProcessing.pause()
        }
    }
    
    @IBAction func playPauseAction(_ sender: UIButton) {
        if sender.isSelected {
            // Pause audio
            audioProcessing.pause()
            stopAudioProcessing()
            isPlaying = false
        } else {
            // Play or resume audio
            
            startAudioProcessing()
            audioProcessing.play()
            isPlaying = true
        }
        sender.isSelected.toggle()
    }

    func startAudioProcessing() {
        timer = Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(updateData), userInfo: nil, repeats: true)
    }

    func stopAudioProcessing() {
        timer?.invalidate()
        timer = nil
    }

    @objc func updateData() {
        data = audioProcessing.fftMagnitudes.map {
            min($0, 32)
        }
        updateBackgroundColor()
    }

    func updateBackgroundColor() {
        // Calculate the average magnitude to determine the brightness
        let averageMagnitude = data.reduce(0, +) / Float(data.count)
        let brightness = CGFloat(averageMagnitude / 32)
        
        // Update the background color of the view
        imgBulb.tintColor = UIColor(hue: 0, saturation: 0, brightness: brightness, alpha: 1)
    }
}
