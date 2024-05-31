//
//  PermissionHandler.swift
//  PermissionManagerDemo
//
//  Created by Mr. Dharmesh on 30/05/24.

/*
 
 //MARK: -  To ensure that your app correctly requests permissions, you need to provide descriptions for each type of permission request in your Info.plist. Here are the keys and suggested descriptions for each permission:
 
 //MARK: - Location:
 Key: NSLocationWhenInUseUsageDescription
 Description: "This app needs access to your location to provide personalized content and services based on your location."
 
 //MARK: - Contacts:
 Key: NSContactsUsageDescription
 Description: "This app needs access to your contacts to allow you to connect with your friends and colleagues easily."
 
 //MARK: - Microphone:
 Key: NSMicrophoneUsageDescription
 Description: "This app needs access to your microphone for recording audio and providing voice recognition features."
 
 //MARK: - Speech Recognition:
 Key: NSSpeechRecognitionUsageDescription
 Description: "This app needs access to speech recognition to convert your speech into text for better user interaction."
 
 //MARK: - Calendar:
 Key: NSCalendarsUsageDescription
 Description: "This app needs access to your calendar to create and manage events and reminders."
 
 //MARK: - Reminders:
 Key: NSRemindersUsageDescription
 Description: "This app needs access to your reminders to help you manage your tasks and notifications."
 
 //MARK: -  Camera:
 Key: NSCameraUsageDescription
 Description: "This app needs access to your camera to take photos and videos."
 
 //MARK: -  Photos:
 Key: NSPhotoLibraryUsageDescription
 Description: "This app needs access to your photo library to select and share photos."
 
 //MARK: - App Tracking:
 Key: NSUserTrackingUsageDescription
 Description: "This app needs permission to track your activity across other companies' apps and websites to deliver personalized ads."
 
 //MARK: - Local Network
 Key:  NSLocalNetworkUsageDescription
 Description: This app requires access to devices on your local network to stream media to your TV and other connected devices.
 
 Bonjour service
    itme: _permissions._tcp
 */

import Foundation
import CoreLocation
import Contacts
import AVFoundation
import Speech
import EventKit
import Photos
import AppTrackingTransparency
import UIKit
import OSLog
import Network

enum AuthorizationType {
    case location
    case contacts
    case microphone
    case speechRecognition
    case calendar
    case reminders
    case camera
    case photos
    case appTracking
    case localNetwork
}

class PermissionHandler: NSObject {
    
    static let shared = PermissionHandler()
    
    //for location permission
    private var locationCompletion: ((Bool) -> Void)?
    let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestPermission(_ permissionType: AuthorizationType, completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            switch permissionType {
            case .location:
                self.requestLocationPermission(completion)
            case .contacts:
                self.requestContactsPermission(completion)
            case .microphone:
                self.requestMicrophonePermission(completion)
            case .speechRecognition:
                self.requestSpeechRecognitionPermission(completion)
            case .calendar:
                self.requestCalendarPermission(completion)
            case .reminders:
                self.requestRemindersPermission(completion)
            case .camera:
                self.requestCameraPermission(completion)
            case .photos:
                self.requestPhotosPermission(completion)
            case .appTracking:
                self.requestAppTrackingPermission(completion)
            case .localNetwork:
                self.requestLocalAreaNeteworkPermission(completion)
            }
        }
    }
    
    func requestLocationPermission(_ completion: @escaping (Bool) -> Void) {
        let status = CLLocationManager.authorizationStatus()

        switch status {
        case .notDetermined:
            locationCompletion = completion
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            showSettingsAlert(for: .location)
            completion(false)
        case .authorizedWhenInUse, .authorizedAlways:
            completion(true)
        @unknown default:
            completion(false)
        }
    }
    
    func requestContactsPermission(_ completion: @escaping (Bool) -> Void) {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        switch status {
        case .notDetermined:
            let store = CNContactStore()
            store.requestAccess(for: .contacts) { granted, _ in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        case .restricted, .denied:
            showSettingsAlert(for: .contacts)
            completion(false)
        case .authorized:
            completion(true)
        @unknown default:
            completion(false)
        }
    }
    
    func requestMicrophonePermission(_ completion: @escaping (Bool) -> Void) {
        let status = AVAudioSession.sharedInstance().recordPermission
        switch status {
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        case .denied:
            showSettingsAlert(for: .microphone)
            completion(false)
        case .granted:
            completion(true)
        @unknown default:
            completion(false)
        }
    }
    
    func requestSpeechRecognitionPermission(_ completion: @escaping (Bool) -> Void) {
        let status = SFSpeechRecognizer.authorizationStatus()
        switch status {
        case .notDetermined:
            SFSpeechRecognizer.requestAuthorization { status in
                DispatchQueue.main.async {
                    completion(status == .authorized)
                }
            }
        case .restricted, .denied:
            showSettingsAlert(for: .speechRecognition)
            completion(false)
        case .authorized:
            completion(true)
        @unknown default:
            completion(false)
        }
    }
    
    func requestCalendarPermission(_ completion: @escaping (Bool) -> Void) {
        let status = EKEventStore.authorizationStatus(for: .event)
        switch status {
        case .notDetermined:
            let store = EKEventStore()
            store.requestAccess(to: .event) { granted, _ in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        case .restricted, .denied:
            showSettingsAlert(for: .calendar)
            completion(false)
        case .authorized:
            completion(true)
        case .fullAccess:
            completion(true)
        case .writeOnly:
            completion(true)
        @unknown default:
            completion(false)
        }
    }
    
    func requestRemindersPermission(_ completion: @escaping (Bool) -> Void) {
        let status = EKEventStore.authorizationStatus(for: .reminder)
        switch status {
        case .notDetermined:
            let store = EKEventStore()
            store.requestAccess(to: .reminder) { granted, _ in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        case .restricted, .denied:
            showSettingsAlert(for: .reminders)
            completion(false)
        case .authorized:
            completion(true)
        case .fullAccess:
            completion(true)
        case .writeOnly:
            completion(true)
        @unknown default:
            completion(false)
        }
    }
    
    func requestCameraPermission(_ completion: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        case .restricted, .denied:
            showSettingsAlert(for: .camera)
            completion(false)
        case .authorized:
            completion(true)
        @unknown default:
            completion(false)
        }
    }
    
    func requestPhotosPermission(_ completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                DispatchQueue.main.async {
                    completion(newStatus == .authorized)
                }
            }
        case .restricted, .denied:
            showSettingsAlert(for: .photos)
            completion(false)
        case .authorized, .limited:
            completion(true)
        @unknown default:
            completion(false)
        }
    }
    
    func requestAppTrackingPermission(_ completion: @escaping (Bool) -> Void) {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                DispatchQueue.main.async {
                    
                    completion(status == .authorized)
                }
            }
        } else {
            completion(true)
        }
    }
    
    func showSettingsAlert(for permission: PermissionType) {
        let permissionNames: [PermissionType: String] = [
            .location: "Location",
            .contacts: "Contacts",
            .microphone: "Microphone",
            .speechRecognition: "Speech Recognition",
            .calendar: "Calendar",
            .reminders: "Reminders",
            .camera: "Camera",
            .photos: "Photos",
            .appTracking: "App Tracking",
            .localNetwork: "Local Network"
        ]
        
        guard let permissionName = permissionNames[permission] else { return }
        
        let alert = UIAlertController(title: "\(permissionName) Permission", message: "Please go to Settings and enable \(permissionName) permission to use this feature.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        })
        
        presentFromTopmostViewController(viewControllerToPresent: alert, animated: true, completion: nil)
    }

}

extension PermissionHandler{

    func presentFromTopmostViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        var key: UIWindow?
        
        if #available(iOS 13, *) {
            key = UIApplication.shared.windows.first { $0.isKeyWindow }
        } else {
            key = UIApplication.shared.keyWindow
        }

        if var topController = key?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.present(viewControllerToPresent, animated: flag, completion: completion)
        }
    }
}

//MARK: - Location Permission Delegate
extension PermissionHandler: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if let completion = locationCompletion {
            let granted = status == .authorizedWhenInUse || status == .authorizedAlways
            completion(granted)
            locationCompletion = nil
        }
    }
}

//MARK: - Local Netework Permission
extension PermissionHandler {
    
    func requestLocalAreaNeteworkPermission(_ completion: @escaping (Bool) -> Void) {
        Task {
            do {
                let isAuthorized = try await self.requestLocalNetworkAuthorization()
                print("Authorization granted: \(isAuthorized)")
                DispatchQueue.main.async {
                    completion(isAuthorized)
                }
            } catch {
                print("Error requesting authorization: \(error)")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
    
    func requestLocalNetworkAuthorization() async throws -> Bool {
        let type = "_permissions._tcp"
        let queue = DispatchQueue(label: "com.permissions.localNetworkAuthCheck")
        
        print("Setup listener.")
        let listener = try NWListener(using: NWParameters(tls: .none, tcp: NWProtocolTCP.Options()))
        listener.service = NWListener.Service(name: UUID().uuidString, type: type)
        listener.newConnectionHandler = { _ in }
        
        print("Setup browser.")
        let parameters = NWParameters()
        parameters.includePeerToPeer = true
        let browser = NWBrowser(for: .bonjour(type: type, domain: nil), using: parameters)
        
        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Bool, Error>) in
                class LocalState {
                    var didResume = false
                }
                let local = LocalState()
                @Sendable func resume(with result: Result<Bool, Error>) {
                    if local.didResume {
                        print("Already resumed, ignoring subsequent result.")
                        return
                    }
                    local.didResume = true
                    
                    listener.stateUpdateHandler = { _ in }
                    browser.stateUpdateHandler = { _ in }
                    browser.browseResultsChangedHandler = { _, _ in }
                    listener.cancel()
                    browser.cancel()
                    
                    continuation.resume(with: result)
                }
                
                if Task.isCancelled {
                    print("Task cancelled before listener & browser started.")
                    resume(with: .failure(CancellationError()))
                    return
                }
                
                listener.stateUpdateHandler = { newState in
                    switch newState {
                    case .setup:
                        print("Listener performing setup.")
                    case .ready:
                        print("Listener ready to be discovered.")
                    case .cancelled:
                        print("Listener cancelled.")
                        resume(with: .failure(CancellationError()))
                    case .failed(let error):
                        print("Listener failed, stopping. \(error)")
                        resume(with: .failure(error))
                    case .waiting(let error):
                        print("Listener waiting, stopping. \(error)")
                        resume(with: .failure(error))
                    @unknown default:
                        print("Ignoring unknown listener state: \(String(describing: newState))")
                    }
                }
                listener.start(queue: queue)
                
                browser.stateUpdateHandler = { newState in
                    switch newState {
                    case .setup:
                        print("Browser performing setup.")
                    case .ready:
                        print("Browser ready to discover listeners.")
                    case .cancelled:
                        print("Browser cancelled.")
                        resume(with: .failure(CancellationError()))
                    case .failed(let error):
                        print("Browser failed, stopping. \(error)")
                        resume(with: .failure(error))
                    case .waiting(let error):
                        switch error {
                        case .dns(DNSServiceErrorType(kDNSServiceErr_PolicyDenied)):
                            print("Browser permission denied, reporting failure.")
                            DispatchQueue.main.async {
                                self.showSettingsAlert(for: .localNetwork)
                            }
                            resume(with: .success(false))
                        default:
                            print("Browser waiting, stopping. \(error)")
                            resume(with: .failure(error))
                        }
                    @unknown default:
                        print("Ignoring unknown browser state: \(String(describing: newState))")
                    }
                }
                
                browser.browseResultsChangedHandler = { results, changes in
                    if results.isEmpty {
                        print("Got empty result set from browser, ignoring.")
                        return
                    }
                    print("Discovered \(results.count) listeners, reporting success.")
                    resume(with: .success(true))
                }
                browser.start(queue: queue)
                
                if Task.isCancelled {
                    print("Task cancelled during listener & browser start. (Some warnings might be logged by the listener or browser.)")
                    resume(with: .failure(CancellationError()))
                    return
                }
            }
        } onCancel: {
            listener.cancel()
            browser.cancel()
        }
    }
}
