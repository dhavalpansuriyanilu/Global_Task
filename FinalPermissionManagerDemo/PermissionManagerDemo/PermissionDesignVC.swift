//
//  PermissionDesignVC.swift
//  PermissionManagerDemo
//
//  Created by Mr. Dharmesh on 29/05/24.
//

import UIKit
//enum PermissionScreenShown: String {
//        case locationShown
//        case contactsShown
//        case microphoneShown
//        case speechRecognitionShown
//        case calendarShown
//        case remindersShown
//        case cameraShown
//        case photosShown
//        case appTrackingShown
//    }

class PermissionDesignVC: UIViewController {
    let permissionManager = PermissionManager()
    @IBOutlet weak var imgPermissionIcon: UIImageView!
    @IBOutlet weak var lblAllowTitle: UILabel!
    @IBOutlet weak var btnAllow: UIButton!
    @IBOutlet weak var lblAllowDiscription: UILabel!
    var permissionType : PermissionType!
    let permissionInfo: [PermissionType: (icon: String, title: String, description: String)] = [
                .location: ("location", "Location Permission", "Allow access to your location to provide personalized content and services based on your location."),
                .contacts: ("contacts", "Contacts Permission", "Allow access to your contacts to connect with your friends and colleagues easily."),
                .microphone: ("microphone", "Microphone Permission", "Allow access to your microphone for recording audio and providing voice recognition features."),
                .speechRecognition: ("speechRecognition", "Speech Recognition Permission", "Allow access to speech recognition to convert your speech into text for better user interaction."),
                .calendar: ("calendar", "Calendar Permission", "Allow access to your calendar to create and manage events and reminders."),
                .reminders: ("reminders", "Reminders Permission", "Allow access to your reminders to help you manage your tasks and notifications."),
                .camera: ("camera", "Camera Permission", "Allow access to your camera to take photos and videos."),
                .photos: ("photos", "Photos Permission", "Allow access to your photo library to select and share photos."),
                .appTracking: ("appTracking", "App Tracking Permission", "Allow permission to track your activity across other companies' apps and websites to deliver personalized ads."),
                .localNetwork: ("localNetwork", "Local Network Permission", "This app requires access to devices on your local network to stream media to your TV and other connected devices.")
            ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async {
            self.btnAllow.layer.cornerRadius = 15
            
            switch self.permissionType {
            case .location:
                if let permissionData = self.permissionInfo[self.permissionType] {
                    self.imgPermissionIcon.image = UIImage(named: permissionData.icon)
                    self.lblAllowTitle.text = permissionData.title
                    self.lblAllowDiscription.text = permissionData.description
                }
            case .contacts:
                if let permissionData = self.permissionInfo[self.permissionType] {
                    self.imgPermissionIcon.image = UIImage(named: permissionData.icon)
                    self.lblAllowTitle.text = permissionData.title
                    self.lblAllowDiscription.text = permissionData.description
                }
            case .microphone:
                if let permissionData = self.permissionInfo[self.permissionType] {
                    self.imgPermissionIcon.image = UIImage(named: permissionData.icon)
                    self.lblAllowTitle.text = permissionData.title
                    self.lblAllowDiscription.text = permissionData.description
                }
            case .speechRecognition:
                if let permissionData = self.permissionInfo[self.permissionType] {
                    self.imgPermissionIcon.image = UIImage(named: permissionData.icon)
                    self.lblAllowTitle.text = permissionData.title
                    self.lblAllowDiscription.text = permissionData.description
                }
            case .calendar:
                if let permissionData = self.permissionInfo[self.permissionType] {
                    self.imgPermissionIcon.image = UIImage(named: permissionData.icon)
                    self.lblAllowTitle.text = permissionData.title
                    self.lblAllowDiscription.text = permissionData.description
                }
            case .reminders:
                if let permissionData = self.permissionInfo[self.permissionType] {
                    self.imgPermissionIcon.image = UIImage(named: permissionData.icon)
                    self.lblAllowTitle.text = permissionData.title
                    self.lblAllowDiscription.text = permissionData.description
                }
            case .camera:
                if let permissionData = self.permissionInfo[self.permissionType] {
                    self.imgPermissionIcon.image = UIImage(named: permissionData.icon)
                    self.lblAllowTitle.text = permissionData.title
                    self.lblAllowDiscription.text = permissionData.description
                }
            case .photos:
                if let permissionData = self.permissionInfo[self.permissionType] {
                    self.imgPermissionIcon.image = UIImage(named: permissionData.icon)
                    self.lblAllowTitle.text = permissionData.title
                    self.lblAllowDiscription.text = permissionData.description
                }
            case .appTracking:
                if let permissionData = self.permissionInfo[self.permissionType] {
                    self.imgPermissionIcon.image = UIImage(named: permissionData.icon)
                    self.lblAllowTitle.text = permissionData.title
                    self.lblAllowDiscription.text = permissionData.description
                }
            case .localNetwork:
                if let permissionData = self.permissionInfo[self.permissionType] {
                    self.imgPermissionIcon.image = UIImage(named: permissionData.icon)
                    self.lblAllowTitle.text = permissionData.title
                    self.lblAllowDiscription.text = permissionData.description
                }
            case .none:
                print("")
           
            }
        }
    }

    @IBAction func allowPermissionAction(_ sender: UIButton) {
        DispatchQueue.main.async {
            switch self.permissionType {
            case .location:
                PermissionManager.shared.requestLocationPermission{ granted in
                    print("Request Location Permission: \(granted)")
                    self.dismiss(animated: true)
                }
            case .contacts:
                PermissionManager.shared.requestContactsPermission{ granted in
                    print("Request Contacts Permission: \(granted)")
                    self.dismiss(animated: true)
                }
            case .microphone:
                PermissionManager.shared.requestMicrophonePermission{ granted in
                    print("Request Microphone Permission: \(granted)")
                    self.dismiss(animated: true)
                }
            case .speechRecognition:
                PermissionManager.shared.requestSpeechRecognitionPermission{  granted in
                    print("Request SpeechRecognition Permission: \(granted)")
                    self.dismiss(animated: true)
                }
            case .calendar:
                PermissionManager.shared.requestCalendarPermission{ granted in
                    print("Request Calendar Permission: \(granted)")
                    self.dismiss(animated: true)
                }
            case .reminders:
                PermissionManager.shared.requestRemindersPermission{ granted in
                    print("Request Reminders Permission: \(granted)")
                    self.dismiss(animated: true)
                }
            case .camera:
                PermissionManager.shared.requestCameraPermission{ granted in
                    print("Request Camera Permission: \(granted)")
                    self.dismiss(animated: true)
                }
            case .photos:
                PermissionManager.shared.requestPhotosPermission{ granted in
                    print("Request Photos Permission: \(granted)")
                    self.dismiss(animated: true)
                }
                
            case .appTracking:
                PermissionManager.shared.requestAppTrackingPermission{ granted in
                    print("Request AppTracking Permission: \(granted)")
                    self.dismiss(animated: true)
                }
            case .localNetwork:
                
                PermissionManager.shared.requestLocalAreaNeteworkPermission{ granted in
                    DispatchQueue.main.async {
                        print("Request LocalArea Netework Permission: \(granted)")
                        self.dismiss(animated: true)
                    }
                }
            case .none:
                print("none")
                self.dismiss(animated: true)
            }
        }
    }
}
