import UIKit
import AVFoundation

let WIDTH = UIScreen.main.bounds.width
let HEIGHT = UIScreen.main.bounds.height

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // Audio-Video capture session
    let captureSession = AVCaptureSession()
    
    // Back-facing camera
    var backFacingCamera: AVCaptureDevice?
    
    // Currently active device
    var currentDevice: AVCaptureDevice?
    
    
    let previewLayer = CALayer()
    let lineShape = CAShapeLayer()
    
    @IBOutlet weak var bulbImage: UIImageView! // Connect this IBOutlet to your bulb image view

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Get devices and create UI
        self.createUI()
    }
    
    // Camera data frame reception queue
    let queue = DispatchQueue(label: "com.camera.video.queue")
    
    // Color selection position
    var center: CGPoint = CGPoint(x: WIDTH/2-15, y: WIDTH/2-15)
    
    // MARK: - Get devices, create custom views
    func createUI() {
        // Set session preset to high resolution photo
        self.captureSession.sessionPreset = AVCaptureSession.Preset.hd1280x720
        // Get devices
        let devices = AVCaptureDevice.devices(for: AVMediaType.video)
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                self.backFacingCamera = device
            }
        }
        
        // Set current device to back-facing camera
        self.currentDevice = self.backFacingCamera
        do {
            // Current device input
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice!)
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable: NSNumber(value: kCMPixelFormat_32BGRA)] as! [String : Any]
            videoOutput.alwaysDiscardsLateVideoFrames = true
            videoOutput.setSampleBufferDelegate(self, queue: queue)
            
            if self.captureSession.canAddOutput(videoOutput) {
                self.captureSession.addOutput(videoOutput)
            }
            self.captureSession.addInput(captureDeviceInput)
        } catch {
            print(error)
            return
        }
        
        // Start audio-video capture session
        DispatchQueue.global().async {
            self.captureSession.startRunning()
        }
       
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
        guard let baseAddr = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0) else {
            return
        }
        let width = CVPixelBufferGetWidthOfPlane(imageBuffer, 0)
        let height = CVPixelBufferGetHeightOfPlane(imageBuffer, 0)
        let bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bimapInfo: CGBitmapInfo = [
            .byteOrder32Little,
            CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)]
        
        guard let content = CGContext(data: baseAddr, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bimapInfo.rawValue) else {
            return
        }
        
        guard let cgImage = content.makeImage() else {
            return
        }
        
        DispatchQueue.main.async {
            self.previewLayer.contents = cgImage
            let color = self.previewLayer.pickColor(at: self.center)
            self.bulbImage.tintColor = color
//            self.view.backgroundColor = color
            self.lineShape.strokeColor = color?.cgColor
        }
    }
    
    func setupUI() {
        previewLayer.bounds = CGRect(x: 0, y: 0, width: WIDTH-30, height: WIDTH-30)
        previewLayer.position = view.center
        previewLayer.contentsGravity = CALayerContentsGravity.resizeAspectFill
        previewLayer.masksToBounds = true
        previewLayer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)))
        view.layer.insertSublayer(previewLayer, at: 0)
        
        // Circular ring
        let linePath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 40, height: 40))
        lineShape.frame = CGRect(x: WIDTH/2-20, y: HEIGHT/2-20, width: 40, height: 40)
        lineShape.lineWidth = 5
        lineShape.strokeColor = UIColor.red.cgColor
        lineShape.path = linePath.cgPath
        lineShape.fillColor = UIColor.clear.cgColor
        self.view.layer.insertSublayer(lineShape, at: 1)
        
        // Dot
        let linePath1 = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 8, height: 8))
        let lineShape1 = CAShapeLayer()
        lineShape1.frame = CGRect(x: WIDTH/2-4, y: HEIGHT/2-4, width: 8, height: 8)
        lineShape1.path = linePath1.cgPath
        lineShape1.fillColor = UIColor(white: 0.7, alpha: 0.5).cgColor
        self.view.layer.insertSublayer(lineShape1, at: 1)
    }
}

public extension CALayer {
    
    /// Get color at a specific position
    ///
    /// - parameter at: Position
    ///
    /// - returns: Color
    public func pickColor(at position: CGPoint) -> UIColor? {
        
        // Array to store target pixel values
        var pixel = [UInt8](repeating: 0, count: 4)
        // Color space is RGB, this determines whether the output color encoding is RGB or other (e.g., YUV)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        // Set bitmap color distribution to RGBA
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        guard let context = CGContext(data: &pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo) else {
            return nil
        }
        // Set context origin offset to target position coordinates
        context.translateBy(x: -position.x, y: -position.y)
        // Render the image into the context
        render(in: context)
        
        return UIColor(red: CGFloat(pixel[0]) / 255.0,
                       green: CGFloat(pixel[1]) / 255.0,
                       blue: CGFloat(pixel[2]) / 255.0,
                       alpha: CGFloat(pixel[3]) / 255.0)
    }
}
