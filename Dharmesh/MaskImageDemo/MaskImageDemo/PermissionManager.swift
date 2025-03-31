//
//  PermissionManager.swift
//  MaskImageDemo
//
//  Created by Mr. Dharmesh on 03/06/24.
//

import Foundation
import AVFoundation
import Photos
import UIKit

enum PermissionType {
    case camera
    case photos
    case microphone
   
}

class PermissionManager: NSObject {
    
    static let shared = PermissionManager()

    override init() {
        super.init()
    }
    
    func requestPermission(_ type: PermissionType, completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            
            switch type {
            case .camera:
                self.requestCameraPermission(completion)
            case .photos:
                self.requestPhotosPermission(completion)
            case .microphone:
                self.requestMicrophonePermission(completion)
            }
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
    
    func showSettingsAlert(for permission: PermissionType) {
        let permissionNames: [PermissionType: String] = [
            .camera: "Camera",
            .photos: "Photos"
        ]
        
        guard let topController = UIApplication.shared.keyWindow?.rootViewController else { return }
        guard let permissionName = permissionNames[permission] else { return }
        
        let alert = UIAlertController(title: "\(permissionName) Permission", message: "Please go to Settings and enable \(permissionName) permission to use this feature.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        })
        
        topController.present(alert, animated: true, completion: nil)
    }
}
