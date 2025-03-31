//
//  ViewController.swift
//  CustomNotification
//
//  Created by MacBook_Air_41 on 14/10/24.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {
    
    var unreadCount: Int {
        get {
            return UserDefaults.standard.integer(forKey: "UnreadNotificationCount")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "UnreadNotificationCount")
            updateBadgeCount()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestNotificationPermission()
        UNUserNotificationCenter.current().delegate = self
        registerNotificationCategory()
    }
    
    func updateBadgeCount() {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = self.unreadCount
        }
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else {
                print("Notification permission denied.")
            }
        }
    }
    
    func registerNotificationCategory1() {
        let viewAction = UNNotificationAction(identifier: "VIEW_IMAGE_ACTION", title: "Expand Image", options: [.foreground])
        let category = UNNotificationCategory(identifier: "IMAGE_CATEGORY", actions: [viewAction], intentIdentifiers: [], options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    func registerNotificationCategory() {
            // Add more interactive actions
            let viewAction = UNNotificationAction(identifier: "VIEW_IMAGE_ACTION", title: "Expand Image", options: [.foreground])
            let openAppAction = UNNotificationAction(identifier: "OPEN_APP_ACTION", title: "Open App", options: [.foreground])
            let dismissAction = UNNotificationAction(identifier: "DISMISS_ACTION", title: "Dismiss", options: [.destructive])
            
            // Register custom category with more actions
            let category = UNNotificationCategory(identifier: "IMAGE_CATEGORY", actions: [viewAction, openAppAction, dismissAction], intentIdentifiers: [], options: [])
            
            UNUserNotificationCenter.current().setNotificationCategories([category])
        }
    
    @IBAction func clickButtonTapped(_ sender: UIButton) {
//        scheduleNotificationWithImage()
        scheduleNotificationWithDynamicContent()
    }
    
    func scheduleNotificationWithImage() {
        let content = UNMutableNotificationContent()
        content.title = "Custom Notification"
        content.body = "Notification with an image."
        content.sound = .defaultCritical
        content.categoryIdentifier = "IMAGE_CATEGORY" // Add category with actions
        
        if let attachment = createImageAttachment(from: "nature1") {
            content.attachments = [attachment]
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        // notification request
        let request = UNNotificationRequest(identifier: "imageNotification", content: content, trigger: trigger)
        
        // Schedule the notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully!")
            }
        }
    }
    
    func scheduleNotificationWithDynamicContent() {
        let content = UNMutableNotificationContent()
        content.title = "Custom Notification"
        content.body = "Notification with an image and custom sound."
        
        if Bundle.main.url(forResource: "music", withExtension: "wav") != nil {
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "music.wav"))
            print("Custom sound set successfully.")
        } else {
            print("Custom sound file not found, playing default sound.")
            content.sound = .default
        }

        content.categoryIdentifier = "IMAGE_CATEGORY" // Add category with actions

        // Add the image attachment
        if let attachment = createImageAttachment(from: "nature1") {
            content.attachments = [attachment]
        }
    
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "imageNotification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully!")
                self.unreadCount += 1
                self.updateBadgeCount()
            }
        }
    }

    
    //MARK: - function to create a notification attachment from an asset image
    func createImageAttachment(from imageName: String) -> UNNotificationAttachment? {
        if let image = UIImage(named: imageName) {
            let directory = FileManager.default.temporaryDirectory
            let imageURL = directory.appendingPathComponent("\(imageName).jpg")
            
            // Convert UIImage to JPEG data and write to URL
            if let imageData = image.jpegData(compressionQuality: 1.0) {
                do {
                    try imageData.write(to: imageURL)
                    let attachment = try UNNotificationAttachment(identifier: imageName, url: imageURL, options: nil)
                    return attachment
                } catch {
                    print("Error creating image attachment: \(error)")
                }
            }
        }
        return nil
    }
}

//MARK: - notification delegate methods
extension ViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == "VIEW_IMAGE_ACTION" {
            print("Expand Image action triggered")
            //show the image in full screen or present another view controller
            if let attachment = response.notification.request.content.attachments.first,
               attachment.url.startAccessingSecurityScopedResource() {
                if let imageData = try? Data(contentsOf: attachment.url), let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        if let imageVC = self.storyboard?.instantiateViewController(withIdentifier: "ImageViewController") as? ImageViewController {
                            imageVC.imageToShow = image 
                            imageVC.modalPresentationStyle = .fullScreen
                            self.present(imageVC, animated: false, completion: nil)
                        }

                    }
                }
                attachment.url.stopAccessingSecurityScopedResource()
            }
        }else if response.actionIdentifier == "OPEN_APP_ACTION" {
            print("Open App action triggered")
            // Handle opening app or navigating to a specific screen
            if let url = URL(string: "https://pixabay.com/sound-effects/search/wav/") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    print("Failed to open the app.")
                }
            }
        } else if response.actionIdentifier == "DISMISS_ACTION" {
            print("Notification dismissed")
        }
        unreadCount = max(0, unreadCount - 1)
        completionHandler()
    }
    
    // Show notification in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound])
        } else {
            completionHandler([.alert, .sound])
        }
    }
}
