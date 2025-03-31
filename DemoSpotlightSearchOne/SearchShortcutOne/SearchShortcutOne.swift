//
//  SearchShortcutOne.swift
//  SearchShortcutOne
//
//  Created by 32_MacBook Air  on 17/03/25.
//

import AppIntents
import UIKit

struct SearchShortcutOne: AppIntent {
    static var title: LocalizedStringResource { "SearchShortcutOne" }
    
    /// Launch your app when the system triggers this intent.
    static let openAppWhenRun: Bool = true
    
    /// Define the method that the system calls when it triggers this event.
    @MainActor
    func perform() async throws -> some IntentResult {
        print("By Coffee sucessfully ✅")
        NotificationCenter.default.post(name: NSNotification.Name("BuyCoffee"), object: nil)
        return .result()
    }
}


// MARK: - Clothes Intent
struct BuyClothesIntent: AppIntent {
    static var title: LocalizedStringResource { "Buy Clothes" }
    static let openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult {
        print("Buy Clothes successfully ✅")
//        NotificationCenter.default.post(name: NSNotification.Name("BuyClothes"), object: nil)
        return .result()
    }
}


// MARK: - Shoes Intent
struct BuyShoesIntent: AppIntent {
    static var title: LocalizedStringResource { "Buy Shoes" }
    static let openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult {
        print("Buy Shoes successfully ✅")
//        NotificationCenter.default.post(name: NSNotification.Name("BuyShoes"), object: nil)
        return .result()
    }
}

// MARK: - Register App Shortcuts
struct DemoAppShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        return [
            AppShortcut(
                intent: SearchShortcutOne(),
                phrases: ["Buy coffee in \(.applicationName)"],
                shortTitle: "Buy Coffee..!",
                systemImageName: "cup.and.saucer.fill"
            ),
            AppShortcut(
                intent: BuyClothesIntent(),
                phrases: ["Buy clothes in \(.applicationName)"],
                shortTitle: "Buy Clothes..!",
                systemImageName: "tshirt.fill"
            ),
            AppShortcut(
                intent: BuyShoesIntent(),
                phrases: ["Buy shoes in \(.applicationName)"],
                shortTitle: "Buy Shoes..!",
                systemImageName: "shoe.fill"
            )
        ]
    }
}
