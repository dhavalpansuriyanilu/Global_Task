//
//  AppDelegate.swift
//  LanguagePopupDesign
//
//  Created by Developer 1 on 31/08/23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

      var window: UIWindow?

      func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
          
          window = UIWindow(frame: UIScreen.main.bounds)
          
          let mainViewController = PermissionVC() // Replace with your actual main view controller
          
          window?.rootViewController = mainViewController
          window?.makeKeyAndVisible()
          
          return true
      }


}

