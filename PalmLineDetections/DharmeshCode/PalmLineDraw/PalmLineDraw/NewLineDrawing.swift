

import UIKit

class NewLineDrawing: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, CAAnimationDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var imageViews: UIImageView!
    @IBOutlet weak var scrollViewToZoom: UIScrollView!
    
    private var shapeLayers: [CAShapeLayer] = []
    private var currentIndex = 0
    private var lines: [String: [CGPoint]] = [:]
    private var keys = ["head", "fate", "heart", "life"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollViewToZoom.delegate = self
        scrollViewToZoom.minimumZoomScale = 1.0
        scrollViewToZoom.maximumZoomScale = 5.0
    }
    
    // MARK: - Select Image Button Action
    @IBAction func selectImageTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Select Image", message: "Choose an option", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "📷 Camera", style: .default) { _ in
            self.openImagePicker(sourceType: .camera)
        }
        let galleryAction = UIAlertAction(title: "🖼️ Photo Library", style: .default) { _ in
            self.openImagePicker(sourceType: .photoLibrary)
        }
        let cancelAction = UIAlertAction(title: "❌ Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(cameraAction)
        alertController.addAction(galleryAction)
        alertController.addAction(cancelAction)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        present(alertController, animated: true)
    }
    
    func openImagePicker(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true)
    }
}

// MARK: - Drawing with Zoom and Pan
extension NewLineDrawing {
    
    func startLineDrawing(shapeLayer: CAShapeLayer, path: UIBezierPath, points: [CGPoint], color: UIColor) {
        guard points.count > 1 else { return }

        // Create a full path with smooth curves
        let fullPath = UIBezierPath()
        fullPath.move(to: points.first!)

        for i in 1..<points.count {
            let controlPoint = CGPoint(
                x: (points[i - 1].x + points[i].x) / 2,
                y: (points[i - 1].y + points[i].y) / 2
            )
            fullPath.addQuadCurve(to: points[i], controlPoint: controlPoint)
        }

        shapeLayer.path = fullPath.cgPath
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.lineCap = .round
        shapeLayer.fillColor = UIColor.clear.cgColor

        // Stroke animation
        let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeAnimation.fromValue = 0.0
        strokeAnimation.toValue = 1.0
        strokeAnimation.duration = 5.0
        strokeAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        strokeAnimation.fillMode = .forwards
        strokeAnimation.isRemovedOnCompletion = false

        shapeLayer.add(strokeAnimation, forKey: "strokeAnimation")
        
        animatePathDrawing(points: points,color: color)
    }
    
    private func animatePathDrawing(points: [CGPoint], color: UIColor) {
        
        let animationDuration: TimeInterval = 5.0
        let interval = animationDuration / Double(points.count)

        // Smooth scrolling and zooming animation
        UIView.animateKeyframes(withDuration: animationDuration, delay: 0, options: [.calculationModeLinear], animations: {
            for (index, currentPoint) in points.enumerated() {
                let delay = Double(index) * interval
                UIView.addKeyframe(withRelativeStartTime: delay / animationDuration, relativeDuration: interval / animationDuration) {
                    let zoomScale: CGFloat = 3.0 // Zoom level
                    let offsetX = max(currentPoint.x * zoomScale - self.scrollViewToZoom.bounds.width / 2, 0)
                    let offsetY = max(currentPoint.y * zoomScale - self.scrollViewToZoom.bounds.height / 2, 0)
                    
                    self.scrollViewToZoom.setZoomScale(zoomScale, animated: false)
                    self.scrollViewToZoom.setContentOffset(CGPoint(x: offsetX, y: offsetY), animated: false)
                }
            }
        }, completion: { _ in
            self.handleAnimationCompletion(points: points, color: color)
        })
    }
    
    // MARK: - Handle Animation Completion
    private func handleAnimationCompletion(points: [CGPoint], color: UIColor) {
        DispatchQueue.main.async {
            if let lastPoint = points.last {
                self.addLabel(at: lastPoint, text: self.getLineName(for: self.currentIndex), color: color)
            }

            self.currentIndex += 1
            if self.currentIndex < self.lines.count {
                self.drawNextLine()
            } else {
                self.resetZoom()
            }
        }
    }

    // Helper function to get line name based on index
    private func getLineName(for index: Int) -> String {
        switch index {
        case 0: return "Head"
        case 1: return "Fate"
        case 2: return "Heart"
        case 3: return "Life"
        default: return ""
        }
    }

    // Function to add label
    private func addLabel(at position: CGPoint, text:String, color: UIColor) {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        label.textColor = color
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.frame = CGRect(x: position.x - 20, y: position.y, width: 40, height: 20)
        label.layer.cornerRadius = 5
        label.clipsToBounds = true
        label.alpha = 0 // Start hidden

        self.imageViews.addSubview(label)
        
        // Animation
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
            label.alpha = 1.0 // Fade-in
        }, completion: nil)
    }
    

    // Reset Zoom
    func resetZoom() {
        UIView.animate(withDuration: 0.8) {
            self.zoomImage()
        }
    }

    // Function to move to the next line
    private func drawNextLine() {
        let colors: [UIColor] = [.red, .blue, .yellow, .green]
        guard currentIndex < keys.count else { return }

        let key = keys[currentIndex]
        guard let points = lines[key], !points.isEmpty else {
            currentIndex += 1
            drawNextLine()
            return
        }

        let shapeLayer = CAShapeLayer()
        shapeLayers.append(shapeLayer) // Store the shapeLayer in the array
        imageViews.layer.addSublayer(shapeLayer)

        let color = colors[currentIndex % colors.count]
        startLineDrawing(shapeLayer: shapeLayer, path: UIBezierPath(), points: points, color: color)
    }

   
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            currentIndex += 1
            drawNextLine()
        }
    }
    
    func zoomImage(){
        guard let imageView = scrollViewToZoom.subviews.first as? UIImageView else { return }

//        // Get the sizes
        let scrollViewSize = scrollViewToZoom.bounds.size
        let imageSize = imageView.image?.size ?? imageView.bounds.size

        // Compute the zoom scale based on imageView size
        let scaleWidth = scrollViewSize.width / imageSize.width
        let scaleHeight = scrollViewSize.height / imageSize.height
        let minScale = min(scaleWidth, scaleHeight)

        // Apply a scaling factor (e.g., 1.5x)
        let zoomScale = minScale

        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
            self.scrollViewToZoom.setZoomScale(1, animated: false)
            self.scrollViewToZoom.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        }) { _ in
            
        }
    }


    // MARK: - Image Picker Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            self.clearPreviousLines()
            let backgroundRemoval = BackgroundRemoval()
            do {
                // Background removal
                let image = try backgroundRemoval.removeBackground(image: resizeImageKeepingAspectRatio(image: selectedImage)!)
                imageViews.image = image
                zoomImage()
                getImageLinePoints(image: image)
            }catch {
                print(error)
            }
            
        }
        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - ScrollView Zooming
extension NewLineDrawing {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageViews
    }
}
extension NewLineDrawing {
    
    // MARK: - Mapping Points to ImageView Coordinates
    func getImageLinePoints(image: UIImage) {
        PalmLineDrawer.shared.uploadImageToAPI(image: image) { keypoints, processedImage in
            DispatchQueue.main.async {
                var tempDict: [String: [CGPoint]] = [:]
                self.lines = [:]
                
                guard let displayedImage = self.imageViews.image else { return }

                // Calculate the scaling factor and offset to map points correctly
                let imageSize = displayedImage.size
                let imageViewSize = self.imageViews.bounds.size
                
                let scaleX = imageViewSize.width / imageSize.width
                let scaleY = imageViewSize.height / imageSize.height
                
                // Calculate the content mode adjustment (assuming aspect fit)
                let aspectWidth = imageViewSize.width / imageSize.width
                let aspectHeight = imageViewSize.height / imageSize.height
                let aspectFitScale = min(aspectWidth, aspectHeight)

                // Center image within image view
                let offsetX = (imageViewSize.width - imageSize.width * aspectFitScale) / 2
                let offsetY = (imageViewSize.height - imageSize.height * aspectFitScale) / 2

                for (key, value) in keypoints ?? [:] {
                    if let val = value as? NSArray {
                        var itempoints: [CGPoint] = []
                        
                        for vals in val {
                            if let val5 = vals as? [CGFloat], val5.count >= 2 {
                                // Convert points based on aspect ratio scaling and offset
                                let x = val5[0] * aspectFitScale + offsetX
                                let y = val5[1] * aspectFitScale + offsetY
                                itempoints.append(CGPoint(x: x, y: y))
                            }
                        }
                        
                        if itempoints.count > 0 {
                            tempDict[key] = itempoints
                        }
                    }
                }
                
                if tempDict.count > 0 {
                    DispatchQueue.main.async {
                        self.lines["head"] = tempDict["head"] ?? []
                        self.lines["heart"] = tempDict["heart"] ?? []
                        self.lines["fate"] = tempDict["fate"] ?? []
                        self.lines["life"] = tempDict["life"] ?? []
                        
                        self.currentIndex = 0
                        self.drawNextLine()

                        print(self.lines)
                    }
                }
            }
        }
    }

    private func clearPreviousLines() {
        for layer in shapeLayers {
            layer.removeFromSuperlayer()
        }
        
        for subview in imageViews.subviews {
            subview.removeFromSuperview()
        }
        
        shapeLayers.removeAll()
        lines.removeAll()
        currentIndex = 0
    }

    
   

}
