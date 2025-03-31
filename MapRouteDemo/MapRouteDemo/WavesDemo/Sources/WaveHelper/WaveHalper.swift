
import Foundation
import UIKit

enum GradientDirection {
    case horizontal
    case vertical
    case diagonalTopLeftToBottomRight
    case diagonalBottomLeftToTopRight
}

extension UIImage {
    
    func tintedWithLinearGradientColors(colorsArr: [CGColor], direction: GradientDirection) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return UIImage()
        }
        context.translateBy(x: 0, y: self.size.height)
        context.scaleBy(x: 1, y: -1)
        
        context.setBlendMode(.normal)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        // Create gradient
        let colors = colorsArr as CFArray
        let space = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorsSpace: space, colors: colors, locations: nil)
        
        // Set start and end points based on direction
        let startPoint: CGPoint
        let endPoint: CGPoint
        
        switch direction {
        case .horizontal:
            startPoint = CGPoint(x: 0, y: self.size.height / 2)
            endPoint = CGPoint(x: self.size.width, y: self.size.height / 2)
        case .vertical:
            startPoint = CGPoint(x: self.size.width / 2, y: 0)
            endPoint = CGPoint(x: self.size.width / 2, y: self.size.height)
        case .diagonalTopLeftToBottomRight:
            startPoint = CGPoint(x: 0, y: 0)
            endPoint = CGPoint(x: self.size.width, y: self.size.height)
        case .diagonalBottomLeftToTopRight:
            startPoint = CGPoint(x: 0, y: self.size.height)
            endPoint = CGPoint(x: self.size.width, y: 0)
        }
        
        // Apply gradient
        context.clip(to: rect, mask: self.cgImage!)
        context.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: .drawsAfterEndLocation)
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return gradientImage!
    }
}

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let r = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let g = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let b = CGFloat(rgb & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}


