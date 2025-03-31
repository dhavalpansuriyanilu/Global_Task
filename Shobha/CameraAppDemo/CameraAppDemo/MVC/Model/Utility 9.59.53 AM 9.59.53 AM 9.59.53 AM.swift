
import Foundation
import UIKit
import  ImageIO

func ShowAlert(title: String, message: String, in vc: UIViewController) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
    vc.present(alert, animated: true, completion: nil)
}

func isValidEmail(testStr:String) -> Bool {
    // print("validate calendar: \(testStr)")
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: testStr)
}



@IBDesignable
class DesignableView: UIView {
}

@IBDesignable
class DesignableButton: UIButton {
}

@IBDesignable
class DesignableLabel: UILabel {
}

extension UIView {
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
}
public extension String {
    func isValidString() -> Bool
    {
      
      let strCheck = self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
      
      let isValid = (strCheck.count > 0 ? true : false)
        
      return isValid;
    }
    func isValidEmailAddress() -> Bool
    {
      //let stricterFilter = false
      //let stricterFilterString = "^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$"
      let laxString = "^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$"
      let emailRegex = laxString//stricterFilter ? stricterFilterString : laxString
      let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
      return emailTest.evaluate(with: self)
    }
}

extension UIImageView {

    public func loadGif(name: String) {
        DispatchQueue.global().async {
            let image = UIImage.gif(name: name)
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }

}

extension UIImage {

    public class func gif(data: Data) -> UIImage? {
        // Create source from data
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("SwiftGif: Source for the image does not exist")
            return nil
        }

        return UIImage.animatedImageWithSource(source)
    }

    public class func gif(url: String) -> UIImage? {
        // Validate URL
        guard let bundleURL = URL(string: url) else {
            print("SwiftGif: This image named \"\(url)\" does not exist")
            return nil
        }

        // Validate data
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(url)\" into NSData")
            return nil
        }

        return gif(data: imageData)
    }

    public class func gif(name: String) -> UIImage? {
        // Check for existance of gif
        guard let bundleURL = Bundle.main
          .url(forResource: name, withExtension: "gif") else {
            print("SwiftGif: This image named \"\(name)\" does not exist")
            return nil
        }

        // Validate data
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }

        return gif(data: imageData)
    }

    internal class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1

        // Get dictionaries
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifPropertiesPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 0)
        if CFDictionaryGetValueIfPresent(cfProperties, Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque(), gifPropertiesPointer) == false {
            return delay
        }

        let gifProperties:CFDictionary = unsafeBitCast(gifPropertiesPointer.pointee, to: CFDictionary.self)

        // Get delay time
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }

        delay = delayObject as? Double ?? 0

        if delay < 0.1 {
            delay = 0.1 // Make sure they're not too fast
        }

        return delay
    }

    internal class func gcdForPair(_ a: Int?, _ b: Int?) -> Int {
        var a = a
        var b = b
        // Check if one of them is nil
        if b == nil || a == nil {
            if b != nil {
                return b!
            } else if a != nil {
                return a!
            } else {
                return 0
            }
        }

        // Swap for modulo
        if a! < b! {
            let c = a
            a = b
            b = c
        }

        // Get greatest common divisor
        var rest: Int
        while true {
            rest = a! % b!

            if rest == 0 {
                return b! // Found it
            } else {
                a = b
                b = rest
            }
        }
    }

    internal class func gcdForArray(_ array: Array<Int>) -> Int {
        if array.isEmpty {
            return 1
        }

        var gcd = array[0]

        for val in array {
            gcd = UIImage.gcdForPair(val, gcd)
        }

        return gcd
    }

    internal class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()

        // Fill arrays
        for i in 0..<count {
            // Add image
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
            }

            // At it's delay in cs
            let delaySeconds = UIImage.delayForImageAtIndex(Int(i),
                source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }

        // Calculate full duration
        let duration: Int = {
            var sum = 0

            for val: Int in delays {
                sum += val
            }

            return sum
            }()

        // Get frames
        let gcd = gcdForArray(delays)
        var frames = [UIImage]()

        var frame: UIImage
        var frameCount: Int
        for i in 0..<count {
            frame = UIImage(cgImage: images[Int(i)])
            frameCount = Int(delays[Int(i)] / gcd)

            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }

        // Heyhey
        let animation = UIImage.animatedImage(with: frames,
            duration: Double(duration) / 1000.0)

        return animation
    }

}
func roundCorners(baseview:UIView,corners: UIRectCorner, radius: CGFloat) {
    let path = UIBezierPath(roundedRect:baseview.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
    let mask = CAShapeLayer()
    mask.path = path.cgPath
    baseview.layer.mask = mask
    }


func addBorder(baseview:UIView, withColor color: UIColor,corner radius: CGFloat, andThickness thickness: CGFloat) {
    baseview.layer.cornerRadius = radius
    baseview.layer.borderColor = color.cgColor
    baseview.layer.borderWidth = thickness
    }


class DataDetector {

private class func _find(all type: NSTextCheckingResult.CheckingType,
                       in string: String, iterationClosure: (String) -> Bool) {
  guard let detector = try? NSDataDetector(types: type.rawValue) else { return }
  let range = NSRange(string.startIndex ..< string.endIndex, in: string)
  let matches = detector.matches(in: string, options: [], range: range)
loop: for match in matches {
  for i in 0 ..< match.numberOfRanges {
      let nsrange = match.range(at: i)
      let startIndex = string.index(string.startIndex, offsetBy: nsrange.lowerBound)
      let endIndex = string.index(string.startIndex, offsetBy: nsrange.upperBound)
      let range = startIndex..<endIndex
      guard iterationClosure(String(string[range])) else { break loop }
  }
}
}

class func find(all type: NSTextCheckingResult.CheckingType, in string: String) -> [String] {
  var results = [String]()
  _find(all: type, in: string) {
      results.append($0)
      return true
  }
  return results
}

class func first(type: NSTextCheckingResult.CheckingType, in string: String) -> String? {
  var result: String?
  _find(all: type, in: string) {
      result = $0
      return false
  }
  return result
}
}

// MARK: PhoneNumber

struct PhoneNumber {
private(set) var number: String
init?(extractFrom string: String) {
  guard let phoneNumber = PhoneNumber.first(in: string) else { return nil }
  self = phoneNumber
}

private init (string: String) { self.number = string }

func makeACall() {
  guard let url = URL(string: "tel://\(number.onlyDigits())"),
        UIApplication.shared.canOpenURL(url) else { return }
  if #available(iOS 10, *) {
      UIApplication.shared.open(url)
  } else {
      UIApplication.shared.openURL(url)
  }
}

static func extractAll(from string: String) -> [PhoneNumber] {
  DataDetector.find(all: .phoneNumber, in: string)
      .compactMap {  PhoneNumber(string: $0) }
}

static func first(in string: String) -> PhoneNumber? {
  guard let phoneNumberString = DataDetector.first(type: .phoneNumber, in: string) else { return nil }
  return PhoneNumber(string: phoneNumberString)
}
}

extension PhoneNumber: CustomStringConvertible { var description: String { number } }

// MARK: String extension

extension String {

// MARK: Get remove all characters exept numbers

func onlyDigits() -> String {
  let filtredUnicodeScalars = unicodeScalars.filter { CharacterSet.decimalDigits.contains($0) }
  return String(String.UnicodeScalarView(filtredUnicodeScalars))
}

var detectedPhoneNumbers: [PhoneNumber] { PhoneNumber.extractAll(from: self) }
var detectedFirstPhoneNumber: PhoneNumber? { PhoneNumber.first(in: self) }
}

@IBDesignable
class GradientView: UIView {
    
    @IBInspectable var startColor: UIColor = UIColor(red: 0.0, green: 0.4118, blue: 1.0, alpha: 0.1) { // #0069ff with 10% opacity
        didSet {
            updateGradient()
        }
    }
    
    @IBInspectable var endColor: UIColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.1) { // #ff0000 with 10% opacity
        didSet {
            updateGradient()
        }
    }
    
    private var gradientLayer: CAGradientLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = self.bounds
    }
    
    private func setupGradient() {
        gradientLayer = CAGradientLayer()
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 1, y: 1)
        gradientLayer.endPoint = CGPoint(x: 0, y: 0)
        gradientLayer.frame = self.bounds
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func updateGradient() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
       
    }
}

extension UIView {
    func setShadow(radius: CGFloat, shadowRadius: CGFloat, corner: CACornerMask, color: UIColor){
            self.layer.cornerRadius = radius
            self.layer.maskedCorners = corner
            self.layer.masksToBounds = false
            self.layer.shadowColor = color.cgColor
            self.layer.shadowOffset = CGSize(width: 1, height: 1)
            self.layer.shadowOpacity = 0.7
            self.layer.shadowRadius = shadowRadius
            self.clipsToBounds = false
        }
}


extension UIViewController {
    func showAlert(title: String?, message: String?, actions: [UIAlertAction]? = nil, preferredStyle: UIAlertController.Style = .alert) {
           let alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
           if actions == nil {
               let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
               alertController.addAction(defaultAction)
           } else {
               actions?.forEach { alertController.addAction($0) }
           }
           self.present(alertController, animated: true, completion: nil)
       }
}
