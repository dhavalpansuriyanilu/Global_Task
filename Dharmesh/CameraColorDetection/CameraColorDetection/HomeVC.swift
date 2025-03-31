//
//  HomeVC.swift
//  CameraColorDetection
//
//  Created by Mr. Dharmesh on 07/06/24.
//

import UIKit

class HomeVC: UIViewController {
    @IBOutlet weak var superView: UIView!
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var innerGlowView: UIView!

    @IBOutlet weak var switchDarkLight: UISwitch!
    @IBOutlet weak var lineChartview: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set initial theme based on the switch state
        updateTheme(isDarkMode: switchDarkLight.isOn)

    }
    
    
    @IBAction func didChangeSwitch(_ sender: UISwitch) {
        updateTheme(isDarkMode: sender.isOn)
    }
    
    private func updateTheme(isDarkMode: Bool) {
        bgImage.image = isDarkMode ? UIImage(named: "backgroundDark") : UIImage(named: "backgroundLight")
        let shadowColor: CGColor = isDarkMode ? UIColor.darkGray.cgColor : UIColor.lightGray.cgColor
        
        
        removeInnerShadow(from: innerGlowView)
        removeInnerShadow(from: lineChartview)
        
        addInnerShadow(to: lineChartview, shadowColor: shadowColor, cornerRadius: lineChartview.layer.frame.height / 2, shadowOpacity: 1, shadowRadius: 5, dx: 20, dy: 20)
        addInnerShadow(to: innerGlowView, shadowColor: shadowColor, cornerRadius: innerGlowView.layer.frame.height / 2, shadowOpacity: 1, shadowRadius: 5, dx: 10, dy: 10)
//        addInnerShadow(to: innerGlowView2, shadowColor: shadowColor, cornerRadius: 30, shadowOpacity: 1, shadowRadius: 5, dx: 30, dy: 30)
        
    }
    
    private func addInnerShadow(to view: UIView, shadowColor:CGColor,cornerRadius: CGFloat,shadowOpacity:Float,shadowRadius:CGFloat, dx: CGFloat, dy: CGFloat) {
        let innerShadow = CALayer()
        innerShadow.frame = view.bounds
        
        // Shadow path (increased insets to make shadow more prominent)
        let path = UIBezierPath(roundedRect: innerShadow.bounds.insetBy(dx: -dx, dy: -dy), cornerRadius: cornerRadius)
        let cutout = UIBezierPath(roundedRect: innerShadow.bounds, cornerRadius: cornerRadius).reversing()
        
        path.append(cutout)
        innerShadow.shadowPath = path.cgPath
        innerShadow.masksToBounds = true
        
        // Shadow properties with uniform shadow offset
        innerShadow.shadowColor = shadowColor
        innerShadow.shadowOffset = CGSize(width: 0, height: 0)  // Uniform shadow
        innerShadow.shadowOpacity = shadowOpacity
        innerShadow.shadowRadius = shadowRadius
        innerShadow.cornerRadius = cornerRadius
        view.layer.cornerRadius = cornerRadius
        view.layer.addSublayer(innerShadow)
    }
    
    private func removeInnerShadow(from view: UIView) {
        view.layer.sublayers?.filter { $0.shadowPath != nil }.forEach { $0.removeFromSuperlayer() }
    }

}


