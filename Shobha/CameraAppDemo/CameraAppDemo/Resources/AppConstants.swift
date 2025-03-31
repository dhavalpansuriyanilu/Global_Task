//
//  AppConstants.swift
//  CameraAppDemo
//
//  Created by MacBook_Air_41 on 02/10/24.
//

import Foundation
import UIKit

struct AppConstants {
    
    static let frequencyKey = "StoredFrequencyValue"
    
    static var currentSliderValue: Float {
        get {
            return UserDefaults.standard.float(forKey: frequencyKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: frequencyKey)
        }
    }
}

public final class DeviceDisplay {
    
    enum DisplayType {
        case unknown
        case iphone4
        case iphone5
        case iphone6
        case iphone6plus
        case iphoneX
        case iphone11
        case iphone12
        case iphone13Max
        case iphone12mini
        case iPadNonRetina
        case iPad
        case iPadProSmall
        case iPadProBig
        
    }
    
    class var width:CGFloat { return UIScreen.main.bounds.size.width }
    class var height:CGFloat { return UIScreen.main.bounds.size.height }
    class var maxLength:CGFloat { return max(width, height) }
    class var minLength:CGFloat { return min(width, height) }
    class var zoomed:Bool { return UIScreen.main.nativeScale >= UIScreen.main.scale }
    class var retina:Bool { return UIScreen.main.scale >= 2.0 }
    class var phone:Bool { return UIDevice.current.userInterfaceIdiom == .phone }
    class var pad:Bool { return UIDevice.current.userInterfaceIdiom == .pad }
    //    class var carplay:Bool { return UIDevice.current.userInterfaceIdiom == .carPlay }
    //    class var tv:Bool { return UIDevice.current.userInterfaceIdiom == .tv }
    class var typeIsLike:DisplayType {
        
        if phone && maxLength == 568 {
            return .iphone5
        }
        else if phone && maxLength == 667 {
            return .iphone6
        }
        else if phone && maxLength == 736 {
            return .iphone6plus
        }
        else if phone && maxLength == 812 {
            return .iphoneX
        }
        else if phone && maxLength == 896 {
            return .iphone11
        }
        else if phone && maxLength == 844 {
            return .iphone12
        }
        
        else if phone && maxLength == 926 {
            return .iphone13Max
        }
        
        else if phone && maxLength == 780 {
            return .iphone12mini
        }
        else if pad && retina && maxLength == 1024 {
            return .iPad
        }else if pad && retina && maxLength == 1112 {
            return .iPadProSmall
        }
        else if pad && maxLength == 1366 {
            return .iPadProBig
        }
        else if phone && maxLength < 568 {
            return .iphone4
        }
        else if pad && !retina {
            return .iPadNonRetina
        }
        return .unknown
    }
}
