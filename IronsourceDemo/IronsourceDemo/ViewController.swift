//
//  ViewController.swift
//  IronsourceDemo
//
//  Created by 29_MackbookAir on 06/05/25.
//

import UIKit
import AppTrackingTransparency
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }

    override func viewDidAppear(_ animated: Bool) {
    }

    @IBAction func initAds(_ sender: UIButton){
        ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
            DispatchQueue.main.async {
                // Setup a timer to remove it after n seconds
                ISCBManager.shared.setupAds()
                ISCBManager.shared.addBannerToView(toView: self)
            }
        })
    }
    
    @IBAction func showIntAd(_ sender: UIButton){
        
        ISCBManager.shared.displayAd(toView: self) {
            print("started")
        } endCompletion: {
            print("ended")
        }

    }
}

