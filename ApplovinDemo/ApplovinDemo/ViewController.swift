//
//  ViewController.swift
//  ApplovinDemo
//
//  Created by 29_MackbookAir on 14/07/25.
//

import UIKit
import AppTrackingTransparency

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
            DispatchQueue.main.async {
                ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                    DispatchQueue.main.async {
                        ApplovinManager.shared.initAppLovinSDK {
                            
                        }
                    }
                })
            }
    }

    @IBAction func loadRewardedAd(){
        ApplovinManager.shared.showRewardedAd {
            print("Add Loaded")
        } endAdCompletion: { status in
            print("Reward granted successfully")
        }
    }
    
    @IBAction func loadInterstitialAd(){
        ApplovinManager.shared.showInterstitialAd {
            print("Add Loaded")
        } endAdCompletion: { status in
            print("Reward granted successfully")
        }
    }
}

