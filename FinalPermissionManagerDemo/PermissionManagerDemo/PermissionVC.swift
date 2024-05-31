//
//  PermissionVC.swift
//  LanguagePopupDesign
//
//  Created by Mr. Dharmesh on 27/05/24.
//
import UIKit

class PermissionVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    @IBAction func requestLocationPermissionAction(_ sender: UIButton) {
        
        PermissionManager.shared.requestPermission(.location, showScreen: true) { granted in
            print("Location permission granted: \(granted)")
        }
        
    }
    @IBAction func requestContactsPermissionAction(_ sender: UIButton) {
        PermissionManager.shared.requestPermission(.contacts, showScreen: true) { granted in
            print("Contacts permission granted: \(granted)")
        }
    }
    @IBAction func requestMicrophonePermissionAction3(_ sender: UIButton) {
        PermissionManager.shared.requestPermission(.microphone, showScreen: true) { granted in
            print("Microphone permission granted: \(granted)")
        }
    }
    @IBAction func requestSpeechRecognitionPermissionAction4(_ sender: UIButton) {
        PermissionManager.shared.requestPermission(.speechRecognition, showScreen: true) { granted in
            print("Speech Recognition permission granted: \(granted)")
        }
    }
    @IBAction func requestCalendarPermissionAction5(_ sender: UIButton) {
        PermissionManager.shared.requestPermission(.calendar, showScreen: true) { granted in
            print("Calendar permission granted: \(granted)")
        }
    }
    @IBAction func requestRemindersPermissionAction6(_ sender: UIButton) {
        PermissionManager.shared.requestPermission(.reminders, showScreen: true) { granted in
            print("Reminders permission granted: \(granted)")
        }
    }
    @IBAction func requestCameraPermissionAction7(_ sender: UIButton) {
        PermissionManager.shared.requestPermission(.camera, showScreen: true) { granted in
            print("Camera permission granted: \(granted)")
        }
    }
    @IBAction func requestPhotosPermissionAction8(_ sender: UIButton) {
        PermissionManager.shared.requestPermission(.photos, showScreen: true) { granted in
            print("Photos permission granted: \(granted)")
        }
    }
   
    @IBAction func requestAppTrackingPermissionAction11(_ sender: UIButton) {
        PermissionManager.shared.requestPermission(.appTracking, showScreen: true) { granted in
            print("App Tracking permission granted: \(granted)")
        }
    }
    
    @IBAction func requestlocalNetworkPermissionAction11(_ sender: UIButton) {
        PermissionManager.shared.requestPermission(.localNetwork, showScreen: true) { granted in
            print("Local Network permission granted: \(granted)")
        }
    }
}
