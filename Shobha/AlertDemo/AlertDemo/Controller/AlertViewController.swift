//
//  AlertViewController.swift
//  AutoAndManualScrollDemo
//
//  Created by 41_MacBook_Air on 13/05/25.
//

import UIKit

class AlertViewController: UIViewController {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var opacityView: UIView!
    
    var animationType: AnimationType = .zoomIn

    override func viewDidLoad() {
        super.viewDidLoad()
        bgView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        bgView.alpha = 0
        opacityView.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.3) {
            self.opacityView.alpha = 0.5
        }
        performAlertAnimation(type: animationType, bgView: bgView, opacityView: opacityView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bgView.layer.cornerRadius = 25
        btnDelete.layer.cornerRadius = 12
    }
    
    func dismissWithAnimation() {
        if animationType == .zoomOut {
            if let bgView = self.view.viewWithTag(999) {
                self.performAlertAnimation(type: .zoomOut, bgView: bgView, opacityView: self.view) {
                    self.dismiss(animated: false)
                }
            } else {
                self.dismiss(animated: false)
            }
        } else {
            self.dismiss(animated: false)
        }
    }
    
    @IBAction func cancelAct( _ sender: UIButton) {
        dismissWithAnimation()
    }
}


