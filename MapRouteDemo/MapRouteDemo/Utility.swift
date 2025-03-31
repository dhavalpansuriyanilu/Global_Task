
import Foundation
import AVFAudio
import UIKit

extension UIView{
    
    func setgradientview(viewgradient:UIView){
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = viewgradient.bounds

        let myColor =  UIColor(red: 37/255, green: 36/255, blue: 43/255, alpha: 1).cgColor
        let mycolour2 = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1).cgColor
        gradientLayer.colors = [myColor,mycolour2]
        let shadowView = UIView(frame: viewgradient.bounds)
        shadowView.layer.shadowColor = UIColor.green.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 2.6, height: 2.6)
        shadowView.layer.shadowRadius = 5.0
        shadowView.layer.shadowOpacity = 1.0
        shadowView.layer.cornerRadius = viewgradient.layer.cornerRadius
        shadowView.layer.masksToBounds = false
        shadowView.clipsToBounds = false
        viewgradient.insertSubview(shadowView, at: 0)
        gradientLayer.locations = [0, 0.25]
        viewgradient.layer.insertSublayer(gradientLayer, at: 1)
    }
    
    func setgradient(viewgradient:UIView){
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = viewgradient.bounds
        gradientLayer.colors = [UIColor(named: "Color1")?.cgColor ?? UIColor.systemPink,
                                UIColor(named: "Color2")?.cgColor ?? UIColor.systemRed, 
                                UIColor(named: "Color3")?.cgColor ?? UIColor.systemOrange]
        // Set the direction of the gradient
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        viewgradient.layer.insertSublayer(gradientLayer, at: 0)
        // Add the gradient layer to the button's layer
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let pathCornes = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let maskShapeLayer = CAShapeLayer()
        maskShapeLayer.path = pathCornes.cgPath
        layer.mask = maskShapeLayer
    }
    
    func applyGradient(with colours: [UIColor], locations: [NSNumber]? = nil, direction: GradientDirection = .horizontal) {
        self.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })  // Remove old gradient

        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations

        switch direction {
        case .horizontal:
            gradient.startPoint = CGPoint(x: 0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1, y: 0.5)
        case .vertical:
            gradient.startPoint = CGPoint(x: 0.5, y: 0)
            gradient.endPoint = CGPoint(x: 0.5, y: 1)
        case .diagonalTopLeftToBottomRight:
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 1, y: 1)
        case .diagonalBottomLeftToTopRight:
            gradient.startPoint = CGPoint(x: 0, y: 1)
            gradient.endPoint = CGPoint(x: 1, y: 0)
        }
        
        self.layer.insertSublayer(gradient, at: 0)
    }

    func applyViewShadow(baseView:UIView,shadowColor: UIColor, opacity: Float, offSet: CGSize, shadowRadius: CGFloat,andThickness thickness: CGFloat, scale: Bool = true) {
        baseView.layer.borderWidth = thickness
        baseView.layer.shadowColor = shadowColor.cgColor
        baseView.layer.shadowOpacity = opacity
        baseView.layer.shadowRadius = shadowRadius
        baseView.layer.shadowOffset = offSet
      }
}


func roundCornersWithBorder(baseview: UIView, corners: UIRectCorner, radius: CGFloat, borderWidth: CGFloat, borderColor: UIColor) {
    for item in baseview.layer.sublayers ?? []{
        if ((item as? CAShapeLayer) != nil){
            item.removeFromSuperlayer()
        }
    }
    
    let path = UIBezierPath(roundedRect: baseview.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
    
    let mask = CAShapeLayer()
    mask.path = path.cgPath
    baseview.layer.mask = mask
    
    // Add border
    let borderLayer = CAShapeLayer()
    borderLayer.frame = baseview.bounds
    borderLayer.path = path.cgPath
    borderLayer.lineWidth = borderWidth
    borderLayer.strokeColor = borderColor.cgColor
    borderLayer.fillColor = UIColor.clear.cgColor
    
    baseview.layer.addSublayer(borderLayer)
}



extension UIViewController {
    func showalertWithTitleAndMessage(title: String, message: String, options: String...,alertStyle:UIAlertController.Style,sender:UIView, completion: @escaping (Int) -> Void) {
        let displayalertController = UIAlertController(title: title, message: message, preferredStyle: alertStyle)
        for (index, option) in options.enumerated() {
            displayalertController.addAction(UIAlertAction.init(title: option, style: .default, handler: { (action) in
                completion(index)
            }))
        }
        if let presenter = displayalertController.popoverPresentationController {
            presenter.sourceView = sender
            presenter.sourceRect = CGRect(x:UIScreen.main.bounds.midX, y: sender.frame.height, width: 0, height: 0)
            presenter.permittedArrowDirections = .up
            }
        
        self.present(displayalertController, animated: true, completion: nil)
    }
}


extension AVAudioPlayerNode {
    var currentTime: TimeInterval {
        get {
            if let nodeTime: AVAudioTime = self.lastRenderTime, let playerTime: AVAudioTime = self.playerTime(forNodeTime: nodeTime) {
                return Double(playerTime.sampleTime) / playerTime.sampleRate
            }
            return 0
        }
        
    }
}

func convertFloatToInt16(floatArray: [Float]) -> [Int16] {
    return floatArray.map {
        Int16(max(-32768, min(32767, $0 * 32768)))  // Scale and clamp to Int16 range
    }
}

//MARK: - Setup multiplier constraint
extension NSLayoutConstraint {
    
    func setMultiplierValue(multiplier:CGFloat) -> NSLayoutConstraint {
        
        let newConstraint = NSLayoutConstraint(
            item: firstItem as Any,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        newConstraint.isActive = true
        
        NSLayoutConstraint.deactivate([self])
        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
    
}


extension UIView {

    func addGradientBorder(colors: [UIColor], lineWidth: CGFloat, gradientDirection: GradientDirection = .horizontal) {
        // First, remove any existing gradient borders
        removeGradientBorder()
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        
        // Set the gradient direction based on the input parameter
        switch gradientDirection {
        case .vertical:
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0) // Top-center
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)   // Bottom-center
        case .horizontal:
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5) // Left-center
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)   // Right-center
//        case .crossLeftToRight:
//            gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0) // Bottom-left
//            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)   // Top-right
//        case .crossRightToLeft:
//            gradientLayer.startPoint = CGPoint(x: 1.0, y: 1.0) // Bottom-right
//            gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)   // Top-left
        case .diagonalTopLeftToBottomRight:
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0) // Top-left
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)   // Bottom-right
        case .diagonalBottomLeftToTopRight:
            gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.0) // Top-right
            gradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)   // Bottom-left
        }
        
        let borderLayer = CAShapeLayer()
        borderLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        borderLayer.lineWidth = lineWidth
        borderLayer.fillColor = nil
        borderLayer.strokeColor = UIColor.black.cgColor
        
        gradientLayer.mask = borderLayer
        
        layer.addSublayer(gradientLayer)
    }
    
    func removeGradientBorder() {
        // Remove any existing gradient border layers
        for layer in layer.sublayers ?? [] {
            if let gradientLayer = layer as? CAGradientLayer {
                gradientLayer.removeFromSuperlayer()
            }
        }
    }
}

