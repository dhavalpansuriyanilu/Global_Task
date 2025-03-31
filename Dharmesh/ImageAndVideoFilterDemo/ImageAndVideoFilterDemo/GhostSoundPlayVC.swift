////
////  GhostSoundPlayVC.swift
////  ScaryGhostSound
////
////  Created by Mac Mini on 21/08/23.
////
//
//import UIKit
//import AVFoundation
//import MediaPlayer
//
//class GhostSoundPlayVC: UIViewController {
//    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
//
//    @IBOutlet weak var playerView: UIView!
//    @IBOutlet weak var replayBtn: UIButton!
//    @IBOutlet var btnShare: UIButton!
//    @IBOutlet var BgImage: UIImageView!
//    @IBOutlet weak var lblOverallDuration: UILabel!
//    @IBOutlet weak var lblcurrentText: UILabel!
//    @IBOutlet weak var playbackSlider: UISlider!
//    @IBOutlet var subViewHolder : UIView!
//    @IBOutlet weak var audioTitlelbl: UILabel!
//
//    var count :Int = 0
//    var position : Int = 0
//    var GhostSounds:[GhostSound] = []
//    var imageCache: [String] = []
//    weak var sliderUpdateTimer: Timer?
//
//    @IBOutlet weak var playButton: UIButton!
//
//    //ViewDidLoad
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        activityIndicator.isHidden = true
//
//        setupUI()
//        playSound()
//
//    }
//
//
//    func setupUI() {
//        playerView.layer.cornerRadius = 10
//        playerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
//
//        sliderUpdateTimer = Timer.scheduledTimer(
//            timeInterval: 0.1,
//            target: self,
//            selector: #selector(updateSlider),
//            userInfo: nil,
//            repeats: true
//        )
//    }
//
//    deinit{
//        GhostSounds.removeAll()
//        if isBeingDismissed {
//            // View controller is being dismissed, release resources
//            view = nil
//        }
//        print("deinit Called of GhostSoundPlayVC")
//    }
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        stopAudio()
//    }
//
//    //Updating Slider
//    @objc func updateSlider(){
//        playbackSlider.value = Float(AudioManager.shared.player?.currentTime ?? 0)
//        lblcurrentText.text = Global.timeFormate(second: Int(AudioManager.shared.player?.currentTime ?? 0))
//    }
//
//     func stopAudio(){
//        Global.stopTimer(timer: sliderUpdateTimer) //stop timer
//        AudioManager.shared.player?.stop()
//    }
//
//    @IBAction func replaybtnAction(_ sender: UIButton) {
//        playSound()
//    }
//
//    //Share Button Atction
//    @IBAction func sharebtnAction(_ sender: UIButton) {
//
//        if !AppConstants.tapSoundPersistent
//        {
//            ghostDetector.playSound(filename:"ButtonClick", extensionName:"mp3")
//        }
//        print("Share button tapped.")
//        ShareManager.share(activityItems:[AudioManager.audioFile as Any], sourceView: btnShare, completion:nil)
//    }
//
//    //top left Back Button
//    @IBAction func backtoSoundList(_ sender: UIButton) {
//
//        if !AppConstants.tapSoundPersistent
//        {
//            ghostDetector.playSound(filename:"ButtonClick", extensionName:"mp3")
//        }
//        self.dismiss(animated: true, completion: nil)
//    }
//
//    //Play Sound Btn
//    @IBAction func playSoundbtn(_ sender: Any) {
//        if AudioManager.shared.player?.isPlaying == true{
//            playButton.isSelected = false
//            AudioManager.shared.player?.stop()
//        }else{
//            playButton.isSelected = true
//            AudioManager.shared.player?.play()
//            playbackSlider.maximumValue = Float(AudioManager.shared.player?.duration ?? 0)
//        }
//    }
//
//    //Play previousSound Btn
//    @IBAction func previousSoundBtn(_ sender: UIButton) {
//
//        if position > 0 {
//            self.playButton.isSelected = false
//            activityIndicator.isHidden = false
//            self.activityIndicator.startAnimating()
//
//            position = position - 1
//            AudioManager.shared.player?.stop()
//            pauseAndPlayAudio()
//        }
//    }
//
//    //Play nextSound Btn
//    @IBAction func nextSoundBtn(_ sender: UIButton) {
//        playNextAudio()
//    }
//
//    //handeling slider ValueChanged
//    @IBAction func sliderValueChanged(_ sender: UISlider) {
//        self.playButton.isSelected = false
//        AudioManager.shared.player?.stop()
//        AudioManager.shared.player?.currentTime = TimeInterval(sender.value)
//        if AudioManager.shared.player?.currentTime == AudioManager.shared.player?.duration{
//            AudioManager.shared.player?.pause()
//            playNextAudio()
//        }
//        AudioManager.shared.player?.prepareToPlay()
//        AudioManager.shared.player?.play()
//        self.playButton.isSelected = true
//    }
//}
//
//extension GhostSoundPlayVC : AVAudioPlayerDelegate{
//
//    //palySound
//    func playSound() {
//        self.activityIndicator.stopAnimating()
//        activityIndicator.isHidden = true
//
//        let audio = GhostSounds[position]
//
//        AudioManager.shared.playSound(withAudio: audio)
//        AudioManager.shared.player?.delegate = self
//        self.playbackSlider.maximumValue = Float(AudioManager.shared.player?.duration ?? 0)
//        self.lblOverallDuration.text = Global.timeFormate(second: Int(AudioManager.shared.player?.duration ?? 0)) //soundDuration
//        self.audioTitlelbl.text = audio.soundName //title
//        self.BgImage.image = UIImage(contentsOfFile: getImage())
//        self.playButton.isSelected = true
//    }
//
//    func getImage()->String{
//        if  let imgPath = Bundle.main.path(forResource: imageCache[position], ofType: "jpg") {
//            return imgPath
//        }else {
//            print("Path not Found")
//            return ""
//        }
//    }
//    // Pause for 1 second
//    func pauseAndPlayAudio(){
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//            self.playButton.isSelected = true
//            self.playSound()
//        }
//    }
//    //play the next audio
//    func playNextAudio() {
//
//        if position < (GhostSounds.count - 1) {
//            self.playButton.isSelected = false
//            activityIndicator.isHidden = false
//            self.activityIndicator.startAnimating()
//
//            position = position + 1
//        }else{
//            position = 0
//        }
//        AudioManager.shared.player?.stop()
//        pauseAndPlayAudio()
//    }
//
//    //AVAudioPlayerDelegate
//    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//        playNextAudio()
//    }
//}
//
//
//extension UIView
//{
//    func cornerRadius(usingCorners corners: UIRectCorner, cornerRadii: CGSize) {
//        weak var path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: cornerRadii)
//        weak var maskLayer = CAShapeLayer()
//        maskLayer?.path = path?.cgPath
//        self.layer.mask = maskLayer
//    }
//}
//
