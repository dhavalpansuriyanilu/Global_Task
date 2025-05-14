//
//  AnimationsViewController.swift
//  AlertDemo
//
//  Created by 41_MacBook_Air on 13/05/25.
//

import UIKit

class AnimationsViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    @IBOutlet weak var animateView : UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animateView.layer.cornerRadius = animateView.frame.height / 2
    }
    
    
    @IBAction func animateButtonAction(_ sender: UIButton) {
        if let presented = self.presentedViewController as? AlertViewController {
            presented.dismiss(animated: false) {
                self.presentAlert(for: sender.tag)
            }
        } else {
            self.presentAlert(for: sender.tag)
        }
    }
    
    private func presentAlert(for tag: Int) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "AlertViewController") as? AlertViewController else { return }
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        switch tag {
        case 0:
            vc.animationType = .fade
        case 1:
            vc.animationType = .scale
        case 2:
            vc.animationType = .rotate
        case 3:
            vc.animationType = .slideFromLeft
        case 4:
            vc.animationType = .slideFromRight
        case 5:
            vc.animationType = .slideFromTop
        case 6:
            vc.animationType = .slideFromBottom
        case 7:
            vc.animationType = .flipFromLeft
        case 8:
            vc.animationType = .flipFromRight
        case 9:
            vc.animationType = .shake
        case 10:
            vc.animationType = .zoomIn
        case 11:
            vc.animationType = .zoomOut
        case 12:
            vc.animationType = .bounce
        case 13:
            vc.animationType = .pulse
        case 14:
            vc.animationType = .linearMovement
        case 15:
            vc.animationType = .flipFromTop
        case 16:
            vc.animationType = .flipFromBottom
        case 17:
            vc.animationType = .curlUp
        case 18:
            vc.animationType = .curlDown
        case 19:
            vc.animationType = .swing
        case 20:
            vc.animationType = .wobble
        case 21:
            vc.animationType = .flash
        case 22:
            vc.animationType = .glow
        case 23:
            vc.animationType = .pop
        case 24:
            vc.animationType = .morph
        case 25:
            vc.animationType = .fall
        case 26:
            vc.animationType = .stretch
        case 27:
            vc.animationType = .collapse
        case 28:
            vc.animationType = .expand
        case 29:
            vc.animationType = .hover
            
        default:
            print("Unknown animation type for tag: \(tag)")
            return
        }
        self.present(vc, animated: false)
    }
}
