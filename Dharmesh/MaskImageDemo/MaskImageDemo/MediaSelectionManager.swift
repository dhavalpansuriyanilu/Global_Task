//
//  MediaSelectionManager.swift
//  MaskImageDemo
//
//  Created by Mr. Dharmesh on 03/06/24.
//
import Foundation
import AVFoundation
import Photos
import UIKit
import BSImagePicker

enum SourceType {
    case camera
    case gallery
}

enum ContentType {
    case images
    case videos
}

class MediaSelectionManager: NSObject {
    static var shared = MediaSelectionManager()
    var contentType: ContentType = .images
    var completionHandler: (([Any]) -> Void)?
    
    
    func mediaSelection(form vc: UIViewController, type: ContentType, quantity: Int) {
        contentType = type
        selectSourceType(from: vc, type: type, quantity: quantity)
    }
}

extension MediaSelectionManager: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
        
    func selectSourceType(from viewController: UIViewController, type: ContentType, quantity: Int) {
        let alert = UIAlertController(title: "Source Type", message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            PermissionManager.shared.requestPermission(.camera) { granted in
                DispatchQueue.main.async {
                    if granted {
                        if type == .videos {
                            PermissionManager.shared.requestPermission(.microphone) { micGranted in
                                micGranted ? self.openCamera(from: viewController) :
                                self.showMicrophonePermissionAlert(in: viewController)
                            }
                        } else { self.openCamera(from: viewController) }
                    } else {
                        self.openSettingForPermission(title: "Camera Permission", description: "Enable camera permissions in device settings.")
                    }
                }
            }
        }
        alert.addAction(cameraAction)
        
        let galleryAction = UIAlertAction(title: "Gallery", style: .default) { _ in
            PermissionManager.shared.requestPermission(.photos) { granted in
                DispatchQueue.main.async {
                    granted ? self.openGalleryForPhotoSelect(from: viewController, type: type, quantity: quantity) :
                    self.openSettingForPermission(title: "Photo Permission", description: "Enable photo library permissions in settings.")
                }
            }
        }
        alert.addAction(galleryAction)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = viewController.view
            popover.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        viewController.present(alert, animated: true)
    }
    
    func showMicrophonePermissionAlert(in viewController: UIViewController) {
        let alert = UIAlertController(title: "Microphone Denied", message: "Audio won't be recorded. Enable microphone permissions in settings.", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .cancel) { _ in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString),
               UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }
        alert.addAction(settingsAction)
        
        let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
            self.openCamera(from: viewController)
        }
        alert.addAction(okAction)
        
        viewController.present(alert, animated: true)
    }
    
    func openSettingForPermission(title: String, description: String) {
        let alertController = UIAlertController(title: title, message: description, preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .cancel) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { success in
                    print("Settings opened: \(success)")
                })
            }
        }
        
        alertController.addAction(settingsAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        
        DispatchQueue.main.async {
            UIApplication.shared.windows.first?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }
}

extension MediaSelectionManager {
        
    func openCamera(from vc: UIViewController) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            vc.showAlertWith(title: "Error", message: "Camera is not available.")
            return
        }
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.mediaTypes = contentType == .videos ? ["public.movie"] : ["public.image"]
        imagePicker.videoQuality = .typeHigh
        imagePicker.allowsEditing = false
        vc.present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let mediaType = info[.mediaType] as? String else {
            picker.dismiss(animated: true, completion: nil)
            return
        }
        
        if mediaType == "public.image" {
            if let image = info[.originalImage] as? UIImage {
                completionHandler?([image])
            }
        } else if mediaType == "public.movie" {
            if let videoURL = info[.mediaURL] as? URL {
                completionHandler?([videoURL])
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func openGalleryForPhotoSelect(from vc: UIViewController, type: ContentType,quantity: Int) {
        let veryLargeNumber = 1_000_000
        let imagePicker = ImagePickerController()
        imagePicker.settings.selection.max = quantity == 0 ? veryLargeNumber : quantity
        imagePicker.settings.theme.selectionStyle = .numbered
        if type == .images{
            imagePicker.settings.fetch.assets.supportedMediaTypes = [.image]
        }else{
            imagePicker.settings.fetch.assets.supportedMediaTypes = [.video]
        }
        
        imagePicker.settings.selection.unselectOnReachingMax = true

        vc.presentImagePicker(imagePicker, select: { asset in
            print("Selected: \(asset)")
        }, deselect: { asset in
            print("Deselected: \(asset)")
        }, cancel: { assets in
            print("Canceled with selections: \(assets)")
        }, finish: { assets in
            print("Finished with selections: \(assets)")
            self.getMediaAssets(from: assets)
        }, completion: {
            print("Completion")
        })
    }

    fileprivate func getMediaAssets(from assets: [PHAsset]) {
        let imageSize = CGSize(width: 500, height: 500)
        let imgRequestOptions = PHImageRequestOptions()
        imgRequestOptions.isSynchronous = true
        imgRequestOptions.deliveryMode = .highQualityFormat
        

        for asset in assets {
            if asset.mediaType == .image {
                PHImageManager.default().requestImage(for: asset,targetSize: imageSize,contentMode: .aspectFit,options: imgRequestOptions){ (image, info) in
                    if let img = image {
                        self.completionHandler?([img])
                    } else if let error = info?[PHImageErrorKey] as? Error {
                        print("Error fetching image for asset: \(error)")
                    } else if let isDegraded = info?[PHImageResultIsDegradedKey] as? Bool, !isDegraded {
                        print("Image fetch returned nil for asset: \(asset) - Reason unknown")
                    }
                }
            } else if asset.mediaType == .video {
                let videoRequestOptions = PHVideoRequestOptions()
                videoRequestOptions.deliveryMode = .highQualityFormat

                PHImageManager.default().requestAVAsset(forVideo: asset, options: videoRequestOptions) { avAsset, audioMix, info in
                    if let avAsset = avAsset as? AVURLAsset {
                        print(avAsset.url)
                        self.completionHandler?([avAsset.url])
                    } else if let error = info?[PHImageErrorKey] as? Error {
                        print("Error fetching video for asset: \(error)")
                    } else {
                        print("Video fetch returned nil for asset: \(asset) - Reason unknown")
                    }
                }
            }
        }

    }
}

extension UIViewController {
    
    func showAlertWith(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
