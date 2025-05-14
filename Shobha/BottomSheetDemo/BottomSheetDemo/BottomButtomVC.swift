//
//  BottomButtomVC.swift
//  AutoAndManualScrollDemo
//
//  Created by 41_MacBook_Air on 12/05/25.
//

import UIKit

class BottomButtomVC: UIViewController {
    
    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var btnC: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var pickerCiew: UIPickerView!
    @IBOutlet weak var closeView: UIView!
    
    private var customBlurEffectView: CustomVisualEffectView?
    var selectedRow : Int = 0

    lazy var blurredView: UIView = {
        let containerView = UIView(frame: self.view.bounds)

        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = CustomVisualEffectView(effect: blurEffect, intensity: 0.0)
        blurView.frame = containerView.bounds
        self.customBlurEffectView = blurView

        let dimmedView = UIView(frame: containerView.bounds)
        dimmedView.backgroundColor = .black.withAlphaComponent(0.0) 

        containerView.addSubview(blurView)
        containerView.addSubview(dimmedView)

        return containerView
    }()

    var list = ["5 mins", "10 mins", "15 mins", "30 mins", "1 hour"]

    override func viewDidLoad() {
        super.viewDidLoad()
        bottomView.isHidden = true
        closeView.isHidden = true
        bottomView.layer.cornerRadius = 20
        btnC.layer.cornerRadius = 12
        btn.layer.cornerRadius = 12
        btnSave.layer.cornerRadius = 12
        closeView.layer.cornerRadius = closeView.frame.height / 2
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func animateBottomView() {
        if blurredView.superview == nil {
            blurredView.alpha = 1
            self.view.addSubview(blurredView)
        }

        self.view.bringSubviewToFront(bottomView)
        self.view.bringSubviewToFront(closeView)

        closeView.isHidden = false
        bottomView.isHidden = false
        blurredView.isHidden = false

        bottomView.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
        closeView.alpha = 0

        let animator = UIViewPropertyAnimator(duration: 0.6, curve: .easeInOut) {
            // First stage - bottom view animation and slight blur
            self.bottomView.transform = CGAffineTransform(translationX: 0, y: 30)
            self.customBlurEffectView?.intensity = 0.5
        }

        animator.addCompletion { _ in
            let animator2 = UIViewPropertyAnimator(duration: 0.6, curve: .linear) {
//                self.bottomView.transform = .identity
                self.customBlurEffectView?.intensity = 0.8
            }
            animator2.startAnimation()
            self.closeView.alpha = 1
        }
        animator.startAnimation()
    }

    @IBAction func btnAction(_ sender: UIButton) {
        animateBottomView()
//        let vc = storyboard?.instantiateViewController(withIdentifier: "BottomSheetController") as! BottomSheetController
//        vc.animateBottomView()
//        vc.modalPresentationStyle = .custom
//        self.present(vc, animated: true)
    }

    @IBAction func closeButtonTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseIn]) {
            self.blurredView.alpha = 0
            self.bottomView.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
        } completion: { _ in
            self.bottomView.isHidden = true
            self.closeView.isHidden = true
            self.blurredView.removeFromSuperview()
        }
        self.closeView.alpha = 0
    }
    
    @IBAction func btnSaveChanges(_ sender: UIButton) {
//        let storyboard = UIStoryboard(name: "Alert", bundle: nil)
//        let vc = storyboard.instantiateViewController(identifier: "AlertViewController") as! AlertViewController
//        vc.modalPresentationStyle = .custom
//        present(vc, animated: true)
    }
}

extension BottomButtomVC : UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return list.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return list[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRow = row
        pickerView.reloadAllComponents()
        print("Selected item: \(list[row])")
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.text = list[row]
        label.font = UIFont.systemFont(ofSize: 25, weight: .medium)
        label.textAlignment = .center
//        label.textColor = .black
        label.textColor = (row == selectedRow) ? UIColor.systemPink : UIColor.black
        return label
    }
}




