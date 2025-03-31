//
//  PermissionHandler.swift
//  PermissionManagerDemo
//
//  Created by Mr. Dharmesh on 30/05/24.

/*
 
 //MARK: -  To ensure that your app correctly requests permissions, you need to provide descriptions for each type of permission request in your Info.plist. Here are the keys and suggested descriptions for each permission:
 
 //MARK: -  Camera:
 Key: NSCameraUsageDescription
 Description: "This app needs access to your camera to take photos and videos."
 
 */

import Foundation
import UIKit
import AVFoundation

enum AuthorizationType {
    case camera
   
}

enum PermissionType {
    case camera
  
}

class PermissionHandler: NSObject {
    
    static let shared = PermissionHandler()

    override init() {
        super.init()
    }
    
    func requestPermission(_ permissionType: AuthorizationType, completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            switch permissionType {
            case .camera:
                self.requestCameraPermission(completion)
         
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
    
   
    func showSettingsAlert(for permission: PermissionType) {
        let permissionNames: [PermissionType: String] = [
            .camera: "Camera",
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
