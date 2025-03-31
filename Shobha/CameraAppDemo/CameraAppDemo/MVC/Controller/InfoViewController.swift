//
//  InfoViewController.swift
//  CameraAppDemo
//
//  Created by MacBook_Air_41 on 03/10/24.
//

import UIKit

class InfoViewController: UIViewController {
    
    @IBOutlet weak var viewBg : UIView!
    @IBOutlet weak var btnClose : UIButton!
    @IBOutlet  var lblTitle : [UILabel]!
    @IBOutlet var lblInfo : [UILabel]!


    override func viewDidLoad() {
        super.viewDidLoad()
        setFont()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        roundCorners(baseview: viewBg, corners: [.topLeft,.topRight], radius: 40)
        
    }
    
    //MARK: - Button Action
    @IBAction func btnCloseButtonTapped(_ sender : UIButton) {
         dismiss(animated: true)
    }
    
    func setFont() {
        lblInfo[0].font = UIFont(name: "WorkSans-SemiBold", size: 16)
        lblInfo[1].font = UIFont(name: "WorkSans-Regular", size: 16)
        lblInfo[2].font = UIFont(name: "WorkSans-SemiBold", size: 16)
        lblInfo[3].font = UIFont(name: "WorkSans-Regular", size: 16)
        lblInfo[4].font = UIFont(name: "WorkSans-SemiBold", size: 16)
        lblInfo[5].font = UIFont(name: "WorkSans-Regular", size: 16)
        lblInfo[6].font = UIFont(name: "WorkSans-SemiBold", size: 16)
        lblInfo[7].font = UIFont(name: "WorkSans-Regular", size: 16)
        
        lblTitle[0].font = UIFont(name: "WorkSans-SemiBold", size: 18)
        lblTitle[1].font = UIFont(name: "WorkSans-Regular", size: 18)
        
        lblInfo[0].text = "What is this?"
        lblInfo[1].text = "Use high-frequency sounds designed for your cat's sensitive hearing. These sounds can catch their attention even when they're not in the same room."
        lblInfo[2].text = "How does it work?"
        lblInfo[3].text = "Cats can hear sounds at much higher frequencies than people. These higher frequency tones (between 0 Hz and 100 Hz) immediately get a cat's attention."
        lblInfo[4].text = "What is this?"
        lblInfo[5].text = "Clickers are event markers that let the cat know it did something you liked. Quick reactions are key, and using the clicker is faster than speaking."
        lblInfo[6].text = "How does it work?"
        lblInfo[7].text = "Clicker training is based on the principle of positive reinforcement. The click sound marks the exact moment your cat performs a desired behavior, helping them associate that action with a reward. The key is timing: click right when your cat does something good, and follow it up with a treat!"
        lblTitle[0].text = "Whistle"
        lblTitle[1].text = "Clicker"

        if DeviceDisplay.typeIsLike == .iphone5 || DeviceDisplay.typeIsLike == .iphone4{
            lblInfo[0].font = UIFont(name: "WorkSans-SemiBold", size: 12)
            lblInfo[1].font = UIFont(name: "WorkSans-Regular", size: 12)
            lblInfo[2].font = UIFont(name: "WorkSans-SemiBold", size: 12)
            lblInfo[3].font = UIFont(name: "WorkSans-Regular", size: 12)
            lblInfo[4].font = UIFont(name: "WorkSans-SemiBold", size: 12)
            lblInfo[5].font = UIFont(name: "WorkSans-Regular", size: 12)
            lblInfo[6].font = UIFont(name: "WorkSans-SemiBold", size: 12)
            lblInfo[7].font = UIFont(name: "WorkSans-Regular", size: 12)
            
            lblTitle[0].font = UIFont(name: "WorkSans-SemiBold", size: 15)
            lblTitle[1].font = UIFont(name: "WorkSans-SemiBold", size: 15)
        }
        
        if DeviceDisplay.typeIsLike == .iphone6 {
            lblInfo[0].font = UIFont(name: "WorkSans-SemiBold", size: 14)
            lblInfo[1].font = UIFont(name: "WorkSans-Regular", size: 14)
            lblInfo[2].font = UIFont(name: "WorkSans-SemiBold", size: 14)
            lblInfo[3].font = UIFont(name: "WorkSans-Regular", size: 14)
            lblInfo[4].font = UIFont(name: "WorkSans-SemiBold", size: 14)
            lblInfo[5].font = UIFont(name: "WorkSans-Regular", size: 12)
            lblInfo[6].font = UIFont(name: "WorkSans-SemiBold", size: 14)
            lblInfo[7].font = UIFont(name: "WorkSans-Regular", size: 14)
            
            lblTitle[0].font = UIFont(name: "WorkSans-SemiBold", size: 16)
            lblTitle[1].font = UIFont(name: "WorkSans-SemiBold", size: 16)
        }
    }

}
