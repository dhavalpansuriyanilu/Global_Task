//
//  AppDelegate.swift
//  DemoSpotlightSearchOne
//
//  Created by 32_MacBook Air  on 17/03/25.
//


import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var launchedShortcutItem: UIApplicationShortcutItem?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // If the app is launched by Quick Action, then take the relevant action
        if let shortcutItem = launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            
            launchedShortcutItem = shortcutItem
            
            // Since, the app launch is triggered by QuicAction, block "performActionForShortcutItem:completionHandler" method from being called.
            return false
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        QuickActionHandler.shared.handleQuickAction(shortcutItem)
    }
    
}


//
//
//import UIKit
//
//@UIApplicationMain
//class AppDelegate: UIResponder, UIApplicationDelegate {
//
//    var launchedShortcutItem: UIApplicationShortcutItem?
//   
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        // Override point for customization after application launch.
//        
//        // If the app is launched by Quick Action, then take the relevant action
//        if let shortcutItem = launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
//            
//            launchedShortcutItem = shortcutItem
//            
//            // Since, the app launch is triggered by QuicAction, block "performActionForShortcutItem:completionHandler" method from being called.
//            return false
//        }
//        return true
//    }
////    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//////        addSearchQuickAction()
////    
////        
////        // If the app is launched by Quick Action, then take the relevant action
////        if let shortcutItem = launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
////            
////            launchedShortcutItem = shortcutItem
////            
////            // Since, the app launch is triggered by QuicAction, block "performActionForShortcutItem:completionHandler" method from being called.
////            return false
////        }
//////        if let shortcutItem = launchOptions?[.shortcutItem] as? UIApplicationShortcutItem {
//////              print("🔥 App Launched via Quick Action: \(shortcutItem.type)")
//////              handleQuickAction(shortcutItem)
//////              return false
//////          }
////        return true
////    }
//
////    func setupQuickActions() {
////        
////            let buyCoffee = UIApplicationShortcutItem(
////                type: "com.yourapp.buycoffee",
////                localizedTitle: "Buy Coffee",
////                localizedSubtitle: nil,
////                icon: UIApplicationShortcutIcon(systemImageName: "cup.and.saucer.fill"),
////                userInfo: nil
////            )
////
////            let buyClothes = UIApplicationShortcutItem(
////                type: "com.yourapp.buyclothes",
////                localizedTitle: "Buy Clothes",
////                localizedSubtitle: nil,
////                icon: UIApplicationShortcutIcon(systemImageName: "tshirt.fill"),
////                userInfo: nil
////            )
////        print("🏁 setupQuickActions")
////            UIApplication.shared.shortcutItems = [buyCoffee, buyClothes]
////        }
//    
//
//    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
//        
//        QuickActionHandler.shared.handleQuickAction(shortcutItem)
//    }
////    func handleQuickAction(_ shortcutItem: UIApplicationShortcutItem) {
////        print("🏁 handleQuickAction called with: \(shortcutItem.type)")
////
////        switch shortcutItem.type {
////        case "com.yourapp.buycoffee":
////            print("📢 Posting BuyCoffee Notification")
////            NotificationCenter.default.post(name: Notification.Name("BuyCoffee"), object: nil)
////        case "com.yourapp.buyclothes":
////            print("📢 Posting BuyClothes Notification")
////            NotificationCenter.default.post(name: Notification.Name("BuyClothes"), object: nil)
////        default:
////            print("⚠️ Unknown Quick Action")
////        }
////    }
//
//    
////    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
////        print("🔥 SceneDelegate: Quick Action triggered")
////        (UIApplication.shared.delegate as? AppDelegate)?.handleQuickAction(shortcutItem)
////        completionHandler(true)
////    }
//
//    // MARK: UISceneSession Lifecycle
//
//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//    
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }
//
//    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
//    }
//}
//
//
////<key>UIApplicationShortcutItems</key>
////<array>
////    <dict>
////        <key>UIApplicationShortcutItemTitle</key>
////        <string>Search</string>
////        <key>UIApplicationShortcutItemSubtitle</key>
////        <string>by product name</string>
////        <key>UIApplicationShortcutItemIconType</key>
////        <string>UIApplicationShortcutIconTypeSearch</string>
////        <key>UIApplicationShortcutItemType</key>
////        <string>QuickAction.Search</string>
////    </dict>
////    <dict>
////        <key>UIApplicationShortcutItemTitle</key>
////        <string>Saved Items</string>
////        <key>UIApplicationShortcutItemIconFile</key>
////        <string>SavedItems</string>
////        <key>UIApplicationShortcutItemType</key>
////        <string>QuickAction.SavedItems</string>
////    </dict>
////    <dict>
////        <key>UIApplicationShortcutItemTitle</key>
////        <string>Cart</string>
////        <key>UIApplicationShortcutItemIconFile</key>
////        <string>cart.png</string>
////        <key>UIApplicationShortcutItemType</key>
////        <string>QuickAction.Cart</string>
////   </dict>
////</array>
