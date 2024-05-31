//
//  PermissionVC2.swift
//  PermissionManagerDemo
//
//  Created by Mr. Dharmesh on 30/05/24.
//

import UIKit

class PermissionVC2: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func requestLocationPermissionAction(_ sender: UIButton) {
        
        PermissionHandler.shared.requestPermission(.location) { granted in
            print("Location permission granted: \(granted)")
        }
        
    }
    @IBAction func requestContactsPermissionAction(_ sender: UIButton) {
        PermissionHandler.shared.requestPermission(.contacts) { granted in
            print("Contacts permission granted: \(granted)")
        }
    }
    @IBAction func requestMicrophonePermissionAction3(_ sender: UIButton) {
        PermissionHandler.shared.requestPermission(.microphone) { granted in
            print("Microphone permission granted: \(granted)")
        }
    }
    @IBAction func requestSpeechRecognitionPermissionAction4(_ sender: UIButton) {
        PermissionHandler.shared.requestPermission(.speechRecognition) { granted in
            print("Speech Recognition permission granted: \(granted)")
        }
    }
    @IBAction func requestCalendarPermissionAction5(_ sender: UIButton) {
        PermissionHandler.shared.requestPermission(.calendar) { granted in
            print("Calendar permission granted: \(granted)")
        }
    }
    @IBAction func requestRemindersPermissionAction6(_ sender: UIButton) {
        PermissionHandler.shared.requestPermission(.reminders) { granted in
            print("Reminders permission granted: \(granted)")
        }
    }
    @IBAction func requestCameraPermissionAction7(_ sender: UIButton) {
        PermissionHandler.shared.requestPermission(.camera) { granted in
            print("Camera permission granted: \(granted)")
        }
    }
    @IBAction func requestPhotosPermissionAction8(_ sender: UIButton) {
        PermissionHandler.shared.requestPermission(.photos) { granted in
            print("Photos permission granted: \(granted)")
        }
    }
   
    @IBAction func requestAppTrackingPermissionAction11(_ sender: UIButton) {
        PermissionHandler.shared.requestPermission(.appTracking) { granted in
            print("App Tracking permission granted: \(granted)")
        }
    }
    
    @IBAction func requestlocalNetworkPermissionAction11(_ sender: UIButton) {
        PermissionHandler.shared.requestPermission(.localNetwork) { granted in
            print("Local Network permission granted: \(granted)")
        }
    }


}
