import UIKit
import AVFoundation

class MaskVC: UIViewController {
    @IBOutlet weak var viewScan: UIView!
    @IBOutlet weak var handImageMask: UIImageView!
    @IBOutlet weak var viewHandCaptureAnimation: UIView!
    @IBOutlet weak var viewLineHandCapture2 : UIView!
    @IBOutlet weak var viewLineHandCapture1 : UIView!
    @IBOutlet weak var viewTopLineHandTC    : NSLayoutConstraint!
    var isAnimatioinStop = false
    var pickedImage : UIImage!
    var maskView = UIImageView()
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var photoOutput: AVCapturePhotoOutput?
    override func viewDidLoad() {
        super.viewDidLoad()
    
           viewHandCaptureAnimation.mask = handImageMask
        
        animation()
        setupCamera()
    }
    
    // Reusable function to apply mask
    func applyMask(to view: UIView, with image: UIImage) {
        let maskLayer = CALayer()
        maskLayer.contents = image.cgImage
        maskLayer.frame = view.bounds
        
        // Optional: Adjust mask layer if needed
        // For example, you can scale or move the mask layer
        // maskLayer.transform = CATransform3DMakeScale(0.5, 0.5, 1)
        // maskLayer.position = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        
        view.layer.mask = maskLayer
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        handImageMask.frame = viewHandCaptureAnimation.bounds
    }

    
    func applyMask(maskName: String) {
        DispatchQueue.main.async { [self] in
            var newMaskImage: UIImage?
            
            newMaskImage = UIImage(named: maskName)
            
            
            self.handImageMask.image = pickedImage
 

            let image  = self.createMaskedImage(originalImage:pickedImage, maskImage: newMaskImage!)

            self.handImageMask.image = image
        }
    }

    //MARK: - With Blur
    func createMaskedImage(originalImage: UIImage, maskImage: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: originalImage) else { return nil }
        let blurFilter = CIFilter(name: "CIGaussianBlur")
        blurFilter?.setValue(ciImage, forKey: kCIInputImageKey)
        blurFilter?.setValue(5, forKey: kCIInputRadiusKey) // Adjust the blur radius as needed
        
        guard let outputImage = blurFilter?.outputImage else { return nil }
        
        let ciContext = CIContext(options: nil)
        guard let cgImage = ciContext.createCGImage(outputImage, from: ciImage.extent) else { return nil }
        
        let blurredImage = UIImage(cgImage: cgImage, scale: originalImage.scale, orientation: originalImage.imageOrientation)
        
        let originalSize = originalImage.size
        
        UIGraphicsBeginImageContextWithOptions(originalSize, false, originalImage.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Flip the context to handle the upside-down issue
        context.translateBy(x: 0, y: originalSize.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        // Draw the blurred image
        context.draw(blurredImage.cgImage!, in: CGRect(origin: .zero, size: originalSize))
        
        // Create a mask from the mask image
        guard let maskCgImage = maskImage.cgImage else { return nil }
        
        // Draw the mask image over the blurred image
        let wdt = ( UIScreen.main.bounds.height/2)// - ((originalSize.height)/2)
        let myImageWidth = maskImage.size.width
        let myImageHeight = maskImage.size.height
        let myViewWidth = originalSize.width

        let ratio = myViewWidth/myImageWidth
        let scaledHeight = myImageHeight * ratio

//        return /*CGSize(width: myViewWidth, height: scaledHeight)*/

        context.clip(to: CGRect(origin: CGPoint.init(x: 0, y: self.view.center.y), size: CGSize(width: myViewWidth, height: scaledHeight)), mask: maskCgImage)
        
        // Apply the mask by clearing the masked area
        context.clear(CGRect(origin: .zero, size: originalSize))
        
        // Get the new image
        let maskedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return maskedImage
    }
  
    func setupCamera() {
        // Create a capture session
        captureSession = AVCaptureSession()
        
        // Get the default camera
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        
        do {
            // Add input to the capture session
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession?.addInput(input)
            
            // Add photo output
            photoOutput = AVCapturePhotoOutput()
            captureSession?.addOutput(photoOutput!)
        } catch {
            print(error)
            return
        }
        
        // Create a preview layer
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        videoPreviewLayer?.videoGravity = .resizeAspectFill
        videoPreviewLayer?.frame = view.bounds
        
        // Add the preview layer to the view's layer
        view.layer.insertSublayer(videoPreviewLayer!, at: 0)
        
        // Start the capture session
        DispatchQueue.global().async {
            self.captureSession?.startRunning()
        }
       
    }
}
extension MaskVC {
    //MARK Aniomation
    class func downSide(lineView:UIView) {
        let shadowWidth: CGFloat = 1.2
        let shadowHeight: CGFloat = 6
        let shadowOffsetX: CGFloat = +50
        let shadowRadius: CGFloat = 5
        let width = lineView.frame.width
        let height = lineView.frame.height + 5
        let shadowPath = UIBezierPath()
        
        shadowPath.move(to: CGPoint(x: shadowRadius / 2, y: height - shadowRadius / 2))
        shadowPath.addLine(to: CGPoint(x: width, y: height - shadowRadius / 2))
        shadowPath.addLine(to: CGPoint(x: width * shadowWidth + shadowOffsetX, y: height + (height * shadowHeight)))
        shadowPath.addLine(to: CGPoint(x: width * -(shadowWidth - 1) + shadowOffsetX, y: height + (height * shadowHeight)))
        lineView.layer.shadowPath = shadowPath.cgPath
        lineView.layer.shadowColor =  UIColor(hex: "#99fdfb").cgColor
//        UIColor.init(named:"#99fdfb")?.cgColor
        
        lineView.layer.shadowRadius = shadowRadius
        lineView.layer.shadowOffset = .zero
        lineView.layer.shadowOpacity = 0.2
    }
    class func upSide(lineView:UIView) {
        let shadowWidth: CGFloat = 1.2
        let shadowHeight: CGFloat = 6
        let shadowOffsetX: CGFloat = +50
        let shadowRadius: CGFloat = 5
        let width = lineView.frame.width
        let height = lineView.frame.height + 5
        let shadowPath = UIBezierPath()
        
        shadowPath.move(to: CGPoint(x: shadowRadius / 2, y: height - shadowRadius / 2))
        shadowPath.addLine(to: CGPoint(x: width, y: height - shadowRadius / 2))
        shadowPath.addLine(to: CGPoint(x: width * shadowWidth + shadowOffsetX, y: height + (height * shadowHeight)))
        shadowPath.addLine(to: CGPoint(x: width * -(shadowWidth - 1) + shadowOffsetX, y: height + (height * shadowHeight)))
        
        lineView.layer.shadowPath = shadowPath.cgPath
        lineView.layer.shadowColor = UIColor(hex: "#99fdfb").cgColor
        //UIColor.init(named:"#99fdfb")?.cgColor
        
        lineView.layer.shadowRadius = shadowRadius
        lineView.layer.shadowOffset = .zero
        lineView.layer.shadowOpacity = 0.2
    }
    
 
}

extension MaskVC {
    
    func animation(){
        self.viewLineHandCapture1.isHidden = false
        self.viewLineHandCapture2.isHidden = false
        viewHandCaptureAnimation.clipsToBounds = true
        topToBottomAnimation()
        viewLineHandCapture2.backgroundColor = UIColor.clear
        MaskVC.upSide(lineView:viewLineHandCapture2)
        MaskVC.downSide(lineView: viewLineHandCapture1)
    }
    
    //MARK: Scaning Animation
    func topToBottomAnimation(){

        self.viewLineHandCapture2.isHidden = true
        self.viewLineHandCapture1.layer.shadowColor =  UIColor(hex: "#99fdfb").cgColor
//        (named:"#99fdfb")?.cgColor
        UIView.animate(withDuration: 2.5,
                       delay: 0.1,
                       options: UIView.AnimationOptions.curveEaseIn,
                       animations: { () -> Void in
            self.viewTopLineHandTC.constant = self.viewHandCaptureAnimation.frame.height + 50
            self.viewHandCaptureAnimation?.layoutIfNeeded()
        }, completion: { (finished) -> Void in
            self.viewLineHandCapture2.isHidden = false
            self.viewLineHandCapture1.layer.shadowColor = UIColor.clear.cgColor
            self.viewTopLineHandTC.constant = 0
            self.viewLineHandCapture1.isHidden = true
            self.viewLineHandCapture2.isHidden = true
            DispatchQueue.main.asyncAfter(deadline:.now() + 0.5, execute:{
                if !self.isAnimatioinStop
                {
                    self.animation()
                }
            })
            
        })
    }
    
    
    func stopAnimationScanning()
    {
        viewHandCaptureAnimation.isHidden = true
        
    }
    func startAnimationScanning()
    {
        viewHandCaptureAnimation.isHidden = false
        
    }
    
}

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        let alpha = CGFloat(1.0)

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
