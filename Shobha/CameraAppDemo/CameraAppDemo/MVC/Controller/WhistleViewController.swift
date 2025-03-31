//
//  WhistleViewController.swift
//  CameraAppDemo
//
//  Created by MacBook_Air_41 on 02/10/24.
//

import UIKit
import AVFAudio

class WhistleViewController: UIViewController {
    @IBOutlet weak var viewOption: UIView!
    @IBOutlet weak var viewPro: UIView!
    @IBOutlet weak var btnSetting: UIButton!
    @IBOutlet weak var btnPro: UIButton!
    @IBOutlet weak var btnWhistle: UIButton!
    @IBOutlet weak var btnClicker: UIButton!
    @IBOutlet weak var viewCenter: UIView!
    @IBOutlet weak var viewWhistle: UIView!
    @IBOutlet weak var viewClicker: UIView!
    @IBOutlet weak var viewHowToUse: UIView!
    @IBOutlet var lblFrequencyValue: UILabel!
    @IBOutlet var FrequencySlider: UISlider!
    @IBOutlet var lblTapToPlay: UILabel!
    @IBOutlet var lblHowToUse: UILabel!
    @IBOutlet weak var gifimage: UIImageView!
    @IBOutlet weak var gifimage1: UIImageView!
    @IBOutlet weak var imgWhistleOnOff: UIImageView!
    @IBOutlet weak var btnPlayClicker: UIButton!
    @IBOutlet weak var imgClicker: UIImageView!


    var isPlay = false
    var isFlag = false
    var isplaying = false
    var isFrequncy:Float = 100
    var isCounting:Int = 0
    private var engine: AVAudioEngine!
    private var player: AVAudioPlayerNode!
    let audioSession = AVAudioSession.sharedInstance()
    var volume: Float?
    var isDone = false
    var horn:AVAudioPlayer = AVAudioPlayer()
    var isPrepered = false
    var timer = Timer()
    var counter = 0
    var isShowedLowVolumeOnce = false
    
    var isWhistle = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async { [self] in
            self.viewOption.setShadow(radius: self.viewOption.frame.height / 2, shadowRadius: 3, corner: [.layerMaxXMaxYCorner,.layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMinXMinYCorner], color: .lightGray)
    
            roundCorners(baseview: self.btnPro, corners: .allCorners, radius: self.btnPro.frame.height / 2)
            roundCorners(baseview: self.btnSetting, corners: .allCorners, radius: self.btnSetting.frame.height / 2)
            roundCorners(baseview: self.viewPro, corners: .allCorners, radius: self.viewPro.frame.height / 2)
            roundCorners(baseview: self.btnWhistle, corners: .allCorners, radius: self.btnWhistle.frame.height / 2)
            roundCorners(baseview: self.btnClicker, corners: .allCorners, radius: self.btnClicker.frame.height / 2)
            roundCorners(baseview: self.viewCenter, corners: .allCorners, radius: self.viewCenter.frame.height / 2)
            roundCorners(baseview: self.viewHowToUse, corners: .allCorners, radius: self.viewHowToUse.frame.height / 2)
        
            if self.isWhistle {
                self.btnWhistle.backgroundColor = .black
                self.btnWhistle.setTitleColor(UIColor(hex: "#FEA532"), for: .normal)
                self.btnClicker.setTitleColor(.black, for: .normal)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let savedSliderValue = UserDefaults.standard.float(forKey: "FrequencySliderValue")
        let sliderValue = savedSliderValue != 0 ? savedSliderValue : 100.0
        
        FrequencySlider.value = AppConstants.currentSliderValue
        lblFrequencyValue.text = "\(Int(AppConstants.currentSliderValue)) kHz"
        
        print("In view will appear slider value: \(FrequencySlider.value)")
        print("In view will appear slider value in label: \(lblFrequencyValue.text)")
        
        let session = AVAudioSession.sharedInstance()
        do
        {
            try session.setCategory(AVAudioSession.Category.playback, options: .defaultToSpeaker)
            try session.setActive(true)
            
        }
        catch let error {
        }
        engine = AVAudioEngine()
        player = AVAudioPlayerNode()
        gifimage.isHidden = true
       // gifimage1.isHidden = true

        self.stopWhistle()
        NotificationCenter.default.post(name: Notification.Name("stopAudioPlaying"),object:nil)
        isPrepered = true
        isCounting = 0
    }
    
    func setUpUI() {
        viewClicker.isHidden = true
        viewWhistle.isHidden = false
      //  gifimage1.isHidden = true
        if UIDevice.current.userInterfaceIdiom == .pad {
            btnWhistle.titleLabel?.font = UIFont(name: "WorkSans-SemiBold", size: 25)
            btnClicker.titleLabel?.font = UIFont(name: "WorkSans-SemiBold", size: 25)
            lblHowToUse.font = UIFont(name: "WorkSans-SemiBold", size: 26)
            lblTapToPlay.font = UIFont(name: "WorkSans-SemiBold", size: 26)

        } else {
            lblHowToUse.font = UIFont(name: "WorkSans-SemiBold", size: 16)
            lblTapToPlay.font = UIFont(name: "WorkSans-SemiBold", size: 16)
            btnWhistle.titleLabel?.font = UIFont(name: "WorkSans-SemiBold", size: 18)
            btnClicker.titleLabel?.font = UIFont(name: "WorkSans-SemiBold", size: 18)
        }
        self.stopWhistle()
        FrequencySlider.value = 50
        FrequencySlider.maximumValue = 100
        lblFrequencyValue.text   = "\(Int(AppConstants.currentSliderValue))" + "\("kHz")"
        lblFrequencyValue.text = "\(Int(AppConstants.currentSliderValue)) kHz"
        

    }
    
    //MARK: - Button Actions
    @IBAction func whistleButtonTapped(_ sender: UIButton) {
        isWhistle = true
        btnWhistle.backgroundColor = .black
        btnWhistle.setTitleColor(UIColor(hex: "#FEA532"), for: .normal)
        
        btnClicker.backgroundColor = .clear
        btnClicker.setTitleColor(.black, for: .normal)
        viewClicker.isHidden = true
        viewWhistle.isHidden = false
        lblHowToUse.font = UIFont(name: "WorkSans-SemiBold", size: 14)
    }
    
    @IBAction func clickerButtonTapped(_ sender: UIButton) {
        stopWhistle()
        isWhistle = false
        btnClicker.backgroundColor = .black
        btnClicker.setTitleColor(UIColor(hex: "#FEA532"), for: .normal)

        btnWhistle.backgroundColor = .clear
        btnWhistle.setTitleColor(.black, for: .normal)
        viewClicker.isHidden = false
        viewWhistle.isHidden = true
    }
    
    @IBAction func settingButtonTapped(_ sender: UIButton) {
        stopWhistle()

    }
    
    @IBAction func proButtonTapped(_ sender: UIButton) {
        stopWhistle()
    }
    
    @IBAction func playWhistleButtonTapped(_ sender: UIButton) {
        isPrepered = true
        if isCounting == 1{
            stopWhistle()
        }else{
            frequencySliderValueDidChanged(FrequencySlider)
            playWhistle()
        }
    }
    
    @IBAction func playClickerButtonTapped(_ sender: UIButton) {
        stopWhistle()
        sender.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        sender.addTarget(self, action: #selector(buttonTouchUpInside(_:)), for: .touchUpInside)
    }
    
    @IBAction func howToUseButtonTapped(_ sender: UIButton) {
        stopWhistle()
        let vc = storyboard?.instantiateViewController(withIdentifier: "InfoViewController") as! InfoViewController
        present(vc, animated: true)
    }
    
    
    //MARK: - Function
    
    @objc func buttonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            self.imgClicker.transform = CGAffineTransform(translationX: 0, y: 10) // Move down 10 points
        }
        startGifImageAnimation()
    }

    @objc func buttonTouchUpInside(_ sender: UIButton) {
        stopClicker()
        self.playClicker()
        UIView.animate(withDuration: 0.1) {
            self.imgClicker.transform = .identity
        }
        resetGifSunriseAnimation()
    }

    func playClicker() {
        // Load the audio file
        guard let path = Bundle.main.path(forResource: "clicker", ofType: "mp3"),
              let url = URL(string: path) else {
            print("Audio file not found")
            return
        }

        do {
            let file = try AVAudioFile(forReading: url)

            // Prepare audio session
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)

            // Create an AVAudioPlayerNode and attach it to the engine
            player = AVAudioPlayerNode()
            engine.attach(player)

            // Create an EQ node and set filter parameters (if needed)
            let EQNode = AVAudioUnitEQ(numberOfBands: 1)
            let filterParams = EQNode.bands[0]
            filterParams.filterType = .parametric
            filterParams.frequency = 1000
            filterParams.bypass = false
            engine.attach(EQNode)

            // Connect player to EQNode and EQNode to mainMixer
            engine.connect(player, to: EQNode, format: file.processingFormat)
            engine.connect(EQNode, to: engine.mainMixerNode, format: file.processingFormat)

            // Schedule the file
            player.scheduleFile(file, at: nil, completionHandler: nil)

            // Prepare and start the engine
            try engine.start()
            
            // Start playing
            player.play()
            isplaying = true

        } catch {
            print("Error setting up audio playback: \(error)")
        }
    }


    func stopClicker() {
        if isplaying {
            player.stop()
            engine.stop()
            player.reset()
            engine.reset()
            isplaying = false
        }
    }

    func startGifImageAnimation() {
        // Animate the GIF image upwards
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut, .repeat], animations: {
            self.gifimage1.transform = CGAffineTransform(translationX: 0, y: -20)
        }, completion: nil)
    }

    // Helper to reset GIF animation
    func resetGifSunriseAnimation() {
        UIView.animate(withDuration: 0.1) {
            self.gifimage1.transform = .identity
        }
    }
    
    // Sliderdalegate method
    @IBAction func frequencySliderValueDidChanged(_ sender: UISlider) {
//        if !isPrepered {
//            return
//        }
//        // Update frequency based on the slider's value
//       // isFrequncy = Float(sender.value)
//        AppConstants.currentSliderValue = sender.value
//        let path = Bundle.main.path(forResource: "dogwhistle", ofType: "wav")!
//        let url = NSURL.fileURL(withPath: path)
//        let file = try? AVAudioFile(forReading: url)
//        let audioFormat = file!.processingFormat
//        let audioFrameCount = UInt32(file!.length)
//        let audioFileBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: audioFrameCount)!
//        do {
//            try file?.read(into: audioFileBuffer)
//        } catch {
//            print("Error reading audio file")
//        }
//        
//        var mainMixer = AVAudioMixerNode()
//        mainMixer = engine.mainMixerNode
//        engine.attach(player)
//        
//        // Create an EQ node and set filter parameters based on frequency
//        let EQNode = AVAudioUnitEQ(numberOfBands: 1)
//        let filterParams = EQNode.bands[0] as AVAudioUnitEQFilterParameters
//        
//        // Update filter type based on frequency
//        switch isFrequncy {
//        case 0...1500:
//            filterParams.filterType = .bandPass
//        case 100...1500:
//            filterParams.filterType = .lowShelf
//        case 2500...5000:
//            filterParams.filterType = .bandStop
//        case 5000...7500:
//            filterParams.filterType = .bandStop
//            filterParams.bandwidth = 2
//            filterParams.gain = 20
//        case 7500...10000:
//            filterParams.filterType = .lowPass
//        case 10000...12500:
//            filterParams.filterType = .resonantHighPass
//        case 15000...17500:
//            filterParams.filterType = .parametric
//        case 17500...20000:
//            filterParams.filterType = .resonantLowPass
//        case 20000...21250:
//            filterParams.filterType = .resonantHighPass
//        case 21250...23750:
//            filterParams.filterType = .highPass
//        case 23750...26750:
//            filterParams.filterType = .highShelf
//        case 26750...28000:
//            filterParams.filterType = .parametric
//        default:
//            filterParams.filterType = .parametric
//        }
//        
//        filterParams.frequency = isFrequncy
//        filterParams.bypass = false
//        
//        engine.attach(EQNode)
//        engine.connect(player, to: EQNode, format: file?.processingFormat)
//        engine.connect(EQNode, to: mainMixer, format: file?.processingFormat)
//        
//        player.scheduleFile(file!, at: nil, completionHandler: nil)
//        
//        engine.prepare()
//        
//        do {
//            try engine.start()
//        } catch {
//            print("Error starting audio engine")
//        }
//        
//        isplaying = true
//        
//        if isCounting == 1 {
//            do {
//                isPlay = true
//                // Set the audio session category to playback
//                try audioSession.setCategory(.playback, mode: .default)
//                try audioSession.setActive(true)
//                volume = audioSession.outputVolume
//                if volume! < 0.2 {
////                    showVolumeAlert()
//                } else {
//                    print("Volume alert not needed")
//                }
//                print("System volume: \(volume!)")
//            } catch {
//                print("Error setting up audio session")
//            }
//            
//            DispatchQueue.global().async {
//                self.player.play()
//            }
////            imgWhistle.image = UIImage(named: "imgwhistleShoadow")
//        } else {
//            playWhistle()
//        }
//        
//        player.volume = Float(sender.value)
//        player.scheduleBuffer(audioFileBuffer, at: nil, options: .loops, completionHandler: nil)
//        
//        print("Frequency: \(isFrequncy)")
//        
////        AppConstants.currentSliderValue = Int(Float(Int(isFrequncy)))
//        
////        lblFrequencyValue.text = "\(Int(AppConstants.currentSliderValue)) kHz"
//        
//        
////        lblFrequencyValue.text = "\(Int(AppConstants.currentSliderValue)) kHz"//.localized(lang: AppConstants.isLanguageApp!)
        ///
        if !isPrepered {
               return
           }
           
           // Save the slider value to UserDefaults
           let sliderValue = sender.value
           UserDefaults.standard.set(sliderValue, forKey: "FrequencySliderValue")
           
           AppConstants.currentSliderValue = sliderValue
           
           print("Changes slider value : \(AppConstants.currentSliderValue)")
            
           let path = Bundle.main.path(forResource: "dogwhistle", ofType: "wav")!
           let url = NSURL.fileURL(withPath: path)
           let file = try? AVAudioFile(forReading: url)
           let audioFormat = file!.processingFormat
           let audioFrameCount = UInt32(file!.length)
           let audioFileBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: audioFrameCount)!
           
           do {
               try file?.read(into: audioFileBuffer)
           } catch {
               print("Error reading audio file")
           }
           
           var mainMixer = AVAudioMixerNode()
           mainMixer = engine.mainMixerNode
           engine.attach(player)
           
           // Create EQ node and set filter parameters based on frequency
           let EQNode = AVAudioUnitEQ(numberOfBands: 1)
           let filterParams = EQNode.bands[0] as AVAudioUnitEQFilterParameters
           
           // Determine the filter type based on the slider frequency value
           switch AppConstants.currentSliderValue {
           case 0...1500:
               filterParams.filterType = .bandPass
           case 100...1500:
               filterParams.filterType = .lowShelf
           case 2500...5000:
               filterParams.filterType = .bandStop
           case 5000...7500:
               filterParams.filterType = .bandStop
               filterParams.bandwidth = 2
               filterParams.gain = 20
           case 7500...10000:
               filterParams.filterType = .lowPass
           case 10000...12500:
               filterParams.filterType = .resonantHighPass
           case 15000...17500:
               filterParams.filterType = .parametric
           case 17500...20000:
               filterParams.filterType = .resonantLowPass
           case 20000...21250:
               filterParams.filterType = .resonantHighPass
           case 21250...23750:
               filterParams.filterType = .highPass
           case 23750...26750:
               filterParams.filterType = .highShelf
           case 26750...28000:
               filterParams.filterType = .parametric
           default:
               filterParams.filterType = .parametric
           }
           
           filterParams.frequency = AppConstants.currentSliderValue
           filterParams.bypass = false
           
           engine.attach(EQNode)
           engine.connect(player, to: EQNode, format: file?.processingFormat)
           engine.connect(EQNode, to: mainMixer, format: file?.processingFormat)
           
           player.scheduleFile(file!, at: nil, completionHandler: nil)
           
           engine.prepare()
           
           do {
               try engine.start()
           } catch {
               print("Error starting audio engine")
           }
           
           isplaying = true
           
           if isCounting == 1 {
               do {
                   isPlay = true
                   try audioSession.setCategory(.playback, mode: .default)
                   try audioSession.setActive(true)
                   volume = audioSession.outputVolume
                   if volume! < 0.2 {
                       // Optionally show a volume alert
                   } else {
                       print("Volume alert not needed")
                   }
                   print("System volume: \(volume!)")
               } catch {
                   print("Error setting up audio session")
               }
               
               DispatchQueue.global().async {
                   self.player.play()
               }
           } else {
               playWhistle()
           }
           
           player.volume = sliderValue
           player.scheduleBuffer(audioFileBuffer, at: nil, options: .loops, completionHandler: nil)
           
           print("Frequency: \(AppConstants.currentSliderValue)")
           
           // Update the frequency label
           lblFrequencyValue.text = "\(Int(AppConstants.currentSliderValue)) kHz"
           print("Display on label: \( lblFrequencyValue.text)")
    }

    func playWhistle(){
        gifimage.isHidden = false
        isCounting = 1
        do {
            try audioSession.setActive(true)
            volume = audioSession.outputVolume
            if volume! < 0.2
            {
//                showVolumeAlert()
                
            }else{
                print("tosted not show")
            }
            print("system volume: \(volume)")
        } catch {
            print("Error Setting Up Audio Session")
        }
        player.play()
        imgWhistleOnOff.image = UIImage(named: "icn_whistleOn")
        view.layer.removeAllAnimations()
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self,
                                          selector: #selector(self.timerDidFire(timer:)), userInfo: nil, repeats: true)
    }
    
    @objc private func timerDidFire(timer: Timer) {
        if isCounting == 1
        {
            UIView.animate(withDuration: 0.2) {
                if self.isDone{
                    self.gifimage.alpha = 1.0
                }else{
                    self.gifimage.alpha = 0.0
                }
            }completion: { isFinished in
                if isFinished{
                    self.isDone.toggle()
                }
            }
            self.counter = counter + 1
            print(timer)
        }
        else{
            timer.invalidate()
        }
    }
    
    @objc func stopWhistle()
    {
        guard let isPlayer = player else {
            return
        }
        isCounting = 0
        player.stop()
        timer.invalidate()
//        imgWhistle.image = UIImage(named: "imgWhistleBlack")
        gifimage.isHidden = true
        imgWhistleOnOff.image = UIImage(named: "icn_whistleOff")
    }
    
    @objc func appDidEnterBackground(){
        isCounting = 0
        timer.invalidate()
        player.stop()
        gifimage.isHidden = true
    }
    
}

extension WhistleViewController {
    @objc func didEndSliderTracking(_ sender: UISlider) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.frequencySliderValueDidChanged(sender)
        }
    }
}
