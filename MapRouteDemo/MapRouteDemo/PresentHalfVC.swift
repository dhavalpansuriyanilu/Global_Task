

import UIKit
enum MusicExtension: CaseIterable {
    case mp3, m4a, caf, flac, wav
}
class PresentHalfVC: UIViewController {
    @IBOutlet weak var bntLine: UIButton!
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var viewExport: UIView!

    @IBOutlet weak var viewSeparated: UIView!
    @IBOutlet weak var viewMixer: UIView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackSaparater: UIStackView!
    @IBOutlet weak var lblExportTitle: UILabel!
    @IBOutlet weak var lblSaparater: UILabel!
    @IBOutlet weak var lblMixer: UILabel!
    
    //music extention view components
    @IBOutlet weak var stackExtetion: UIStackView!
    @IBOutlet weak var subViewExport: UIView!
    
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var view4: UIView!
    @IBOutlet weak var view5: UIView!
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var label5: UILabel!
    
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn3: UIButton!
    @IBOutlet weak var btn4: UIButton!
    @IBOutlet weak var btn5: UIButton!
    var musicExt: MusicExtension = .mp3  // Default selection
    var isExpandingView = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGestureRecognizers()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async {
            self.subViewExport.alpha = 0
            self.viewExport.applyGradient(with: [UIColor(hex:"#25242B"),UIColor(hex:"#000000")],direction: .vertical)
            self.lblsTextSetup()
            self.openExtentionSelection(isExpanded: false)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            self.viewExport.roundCorners(corners: [.topLeft,.topRight], radius: 30)
            let radius: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 25 : 20
            self.viewSeparated.roundCorners(corners: .allCorners, radius: radius)
            self.viewMixer.roundCorners(corners: .allCorners, radius: radius)
            self.shadowAdd()
            self.bntLine.roundCorners(corners: .allCorners, radius: self.bntLine.layer.frame.height / 2)
            self.viewExport.applyGradient(with: [UIColor(hex:"#25242B"),UIColor(hex:"#000000")],direction: .vertical)
            //extentionView
            self.view1.roundCorners(corners: .allCorners, radius: 20)
            self.view2.roundCorners(corners: .allCorners, radius: 20)
            self.view3.roundCorners(corners: .allCorners, radius: 20)
            self.view4.roundCorners(corners: .allCorners, radius: 20)
            self.view5.roundCorners(corners: .allCorners, radius: 20)
        }
    }
    func shadowAdd(){
        viewExport.layer.shadowColor = UIColor.white.cgColor
        viewExport.layer.shadowOpacity = 1
        viewExport.layer.shadowOffset = CGSize.zero
        viewExport.layer.shadowRadius = 8
    }
    
    @IBAction func separatedAction(_ sender: UIButton) {
        openExtentionSelection(isExpanded: true)
    }
    
    @IBAction func mixerAction(_ sender: UIButton) {
        openExtentionSelection(isExpanded: true)
    }
    
    @IBAction func selectMusicExtension(_ sender: UIButton) {
        switch sender {
        case btn1:
            musicExt = .mp3
        case btn2:
            musicExt = .m4a
        case btn3:
            musicExt = .caf
        case btn4:
            musicExt = .flac
        case btn5:
            musicExt = .wav
        default: return
        }
        print("Selected music extension: \(musicExt)")
        openExtentionSelection(isExpanded: false)
    }
    
    func lblsTextSetup(){
        lblExportTitle.text = "Export"
        lblSaparater.text = "Separated"
        lblMixer.text = "Mixer"
        
        label1.text = ".MP3"
        label2.text = ".m4a"
        label3.text = ".caf"
        label4.text = ".Flac"
        label5.text = ".wav"
        
    }
    
}

extension PresentHalfVC {
    
    func openExtentionSelection(isExpanded:Bool){
        if isExpanded {
            isExpandingView = true
            UIView.animate(withDuration: 0.5, animations: {
                self.subViewExport.alpha = 1
                self.stackSaparater.isHidden = true
                self.stackExtetion.isHidden = false
                let height: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 650 : 550
                self.heightConstraint.constant = height
 
                self.view.layoutIfNeeded() // Ensure layout updates
            }) { _ in
                
            }
        }else{
            isExpandingView = false
            let height: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 450 : 380
            self.heightConstraint.constant = height
            self.subViewExport.alpha = 0
            self.stackSaparater.isHidden = false
            self.stackExtetion.isHidden = true
        }
    }
}

//SwipeDown code
extension PresentHalfVC: UIGestureRecognizerDelegate {
    
    @objc func tapToDismiss(){
        dissmiss()
    }
    
    func dissmiss(){
        if isExpandingView {
            openExtentionSelection(isExpanded: false)
        }else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    private func setupGestureRecognizers() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeAction(swipe:)))
        swipeDown.direction = UISwipeGestureRecognizer.Direction.down
        viewExport.addGestureRecognizer(swipeDown)
        
        let swipeDownBlure = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeAction(swipe:)))
        swipeDownBlure.direction = UISwipeGestureRecognizer.Direction.down
        mainView.addGestureRecognizer(swipeDownBlure)
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapToDismiss))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        mainView.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func swipeAction(swipe: UISwipeGestureRecognizer) {
        dissmiss()
    }
}
