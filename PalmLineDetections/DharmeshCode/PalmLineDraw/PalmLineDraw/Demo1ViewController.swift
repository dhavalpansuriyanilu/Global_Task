import UIKit
import PhotosUI

class ViewController2: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate {
   
    @IBOutlet weak var imageViews: UIImageView!
    @IBOutlet weak var scrollViewToZoom: UIScrollView!
    private var lines: [String: [CGPoint]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollViewToZoom.delegate = self
        scrollViewToZoom.minimumZoomScale = 1.0
        scrollViewToZoom.showsHorizontalScrollIndicator = false
        scrollViewToZoom.showsVerticalScrollIndicator = false

        
    }
    
    // MARK: - Select Image Button Action
    @IBAction func selectImageTapped(_ sender: UIButton) {
        openImagePicker(sourceType: .photoLibrary)
    }
    // MARK: - Open Image Picker
    func openImagePicker(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true)
    }
    
    // MARK: - PHPicker Delegate
    // MARK: - Image Picker Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            imageViews.image = selectedImage
            getImageLinePoints(image: selectedImage)
        }
        picker.dismiss(animated: true)
    }
    // MARK: - Drawing with Animation
    private func drawLinesWithAnimation(lines: [String: [CGPoint]]) {
        imageViews.layer.sublayers?.removeAll() // Clear existing lines

        guard let imageSize = imageViews.image?.size else { return }
        let scaleX = imageViews.bounds.width / imageSize.width
        let scaleY = imageViews.bounds.height / imageSize.height
        
        var delay: CFTimeInterval = 0
        
        // Function to Zoom to Point
        func zoomToPoint(_ point: CGPoint, zoomScale: CGFloat) {
            let scrollViewSize = scrollViewToZoom.bounds.size
            let zoomRectWidth = scrollViewSize.width / zoomScale
            let zoomRectHeight = scrollViewSize.height / zoomScale
            let zoomRect = CGRect(
                x: point.x - (zoomRectWidth / 2),
                y: point.y - (zoomRectHeight / 2),
                width: zoomRectWidth,
                height: zoomRectHeight
            )
            scrollViewToZoom.zoom(to: zoomRect, animated: true)
        }

        for (_, points) in lines {
            guard points.count > 1 else { continue }

            let path = UIBezierPath()
            let startPoint = CGPoint(x: points.first!.x * scaleX, y: points.first!.y * scaleY)
            path.move(to: startPoint)
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.strokeColor = UIColor.red.cgColor
            shapeLayer.lineWidth = 2
            shapeLayer.fillColor = UIColor.clear.cgColor

            // Pehle point ko center pe zoom karo
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                zoomToPoint(startPoint, zoomScale: 3.0)
            }
            
            // Animate Line Drawing
            for (index, point) in points.dropFirst().enumerated() {
                let scaledPoint = CGPoint(x: point.x * scaleX, y: point.y * scaleY)
                path.addLine(to: scaledPoint)
                
                // Each point pe zoom karna
                DispatchQueue.main.asyncAfter(deadline: .now() + delay + (0.5 * Double(index))) {
                    zoomToPoint(scaledPoint, zoomScale: 3.0)
                }
            }
            
            shapeLayer.path = path.cgPath
            shapeLayer.strokeEnd = 0
            
            // Animate Line Drawing
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = 0
            animation.toValue = 1
            animation.duration = 1.5
            animation.beginTime = CACurrentMediaTime() + delay
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
            shapeLayer.add(animation, forKey: "drawLineAnimation")
            shapeLayer.strokeEnd = 1
            imageViews.layer.addSublayer(shapeLayer)
            
            delay += 2.0 // Next line animation ke liye delay
        }
    }




}
extension ViewController2 {
    // MARK: - Mapping Points to ImageView Coordinates
    func getImageLinePoints(image: UIImage) {
        uploadImageToAPI(image: image) { keypoints, processedImage in
            DispatchQueue.main.async {
                var tempDict: [String: [CGPoint]] = [:]
                self.lines = [:]

                for (key, value) in keypoints ?? [:]{
                    if let val = value as? NSArray{
                        var itempoints: [CGPoint] = []
                        for vals in val{
                            if let val5 = vals as? [CGFloat]{
                                if val5.count >= 2{
                                    let x = val5[0]
                                    let y = val5[1]
                                    itempoints.append(CGPoint(x: x, y: y))
                                }
                            }
                            if itempoints.count > 0{
                                tempDict[key] = itempoints
                            }
                        }
                    }
                }

                if !tempDict.isEmpty {
                    DispatchQueue.main.async {
                        self.lines["head"] = tempDict["head"] ?? []
                        self.lines["heart"] = tempDict["heart"] ?? []
                        self.lines["fate"] = tempDict["fate"] ?? []
                        self.lines["life"] = tempDict["life"] ?? []
                        self.drawLinesWithAnimation(lines: self.lines)
                    }
                }
            }
        }
    }
    
    func uploadImageToAPI(image: UIImage, completion: @escaping ([String: Any]?, UIImage?) -> Void) {
        let url = URL(string: "http://0.0.0.0:8000/predict/")!//"http://127.0.0.1:8000/predict/"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Convert UIImage to JPEG Data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to data")
            completion(nil, nil)
            return
        }
        
        let filename = "image.jpg"
        
        // Add image file to request body
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        // Perform the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("❌ Error: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil, nil)
                return
            }
            
            // Parse JSON Response
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let keypoints = json["keypoints"] as? [String: Any]
                    if let base64ImageString = json["image_base64"] as? String,
                       let imageData = Data(base64Encoded: base64ImageString),
                       let outputImage = UIImage(data: imageData) {
                        DispatchQueue.main.async {
                            completion(keypoints, outputImage)
                        }
                        return
                    }
                }
            } catch {
                print("❌ JSON Parsing Error: \(error.localizedDescription)")
            }
            
            DispatchQueue.main.async {
                completion(nil, nil)
            }
        }
        
        task.resume()
    }
}
