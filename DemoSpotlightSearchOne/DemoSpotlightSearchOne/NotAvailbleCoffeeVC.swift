//
//  ViewController.swift
//  DemoSpotlightSearchAppShortcuts
//
//  Created by 32_MacBook Air  on 17/03/25.
//

import UIKit
import CoreSpotlight
import UniformTypeIdentifiers

class NotAvailbleCoffeeVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("✅ NotAvailbleCoffeeVC Loaded")
        QuickActionHandler.shared.configDynamicQuickActions()
        // Register notification observer
        NotificationCenter.default.addObserver(self, selector: #selector(openShowCoffeeVC), name: .buyCoffee, object: nil)
            
        
//        setupSpotlightSearch()
        
//        removeIndexedItems() // Clear old indexes
//          DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//              indexOffer()
//              indexCollection()
//          }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        guard
            let appDelegate  = UIApplication.shared.delegate as? AppDelegate,
            let shortcutItem = appDelegate.launchedShortcutItem
            else {return}
        
        QuickActionHandler.shared.handleQuickAction(shortcutItem)
    }
    @objc func openShowCoffeeVC() {
        print("🔥 Received Buy Coffee Notification ✅")
        
        let showCoffeeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShowCoffeeVC") as! ShowCoffeeVC

        if let navController = self.navigationController {
            navController.pushViewController(showCoffeeVC, animated: true)
        } else {
            showCoffeeVC.modalPresentationStyle = .fullScreen
            present(showCoffeeVC, animated: true, completion: nil)
        }
    }

    
//    @objc func openShowCoffeeVC() {
//        print("Received Buy Coffee Notification ✅")
//        
//        let showCoffeeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShowCoffeeVC") as! ShowCoffeeVC
//        self.navigationController?.pushViewController(showCoffeeVC, animated: true)
//        
//        
//          /// Get the active window scene
////          guard let windowScene = UIApplication.shared.connectedScenes
////                  .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
////                let window = windowScene.windows.first else {
////              return
////          }
////
////          let storyboard = UIStoryboard(name: "Main", bundle: nil)
////          if let showCoffeeVC = storyboard.instantiateViewController(withIdentifier: "ShowCoffeeVC") as? ShowCoffeeVC {
////              
////              if let rootVC = window.rootViewController {
////                  rootVC.modalPresentationStyle = .fullScreen
//////                  rootVC.navigationController?.pushViewController(showCoffeeVC, animated: true)
////                  rootVC.present(showCoffeeVC, animated: true)
////              }
////          }
//      }

//    func setupSpotlightSearch() {
//        let activity = NSUserActivity(activityType: "com.yourapp.shortcut.reorder")
//        activity.title = "Reorder"
//        activity.userInfo = ["action": "reorder"]
//        activity.isEligibleForSearch = true
//        activity.isEligibleForPrediction = true
//        activity.persistentIdentifier = NSUserActivityPersistentIdentifier("com.yourapp.shortcut.reorder")
//        
//        self.userActivity = activity
//        activity.becomeCurrent()
//    }
}

