//
//  AppDelegate.swift
//  PalmLineDraw
//
//  Created by 29_MackbookAir on 10/03/25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}



/*
 import UIKit

 class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate {
     
     @IBOutlet weak var imageView: UIImageView!  // Connect this in your storyboard
     @IBOutlet weak var scrollViewToZoom: UIScrollView!

     private var shapeLayers: [CAShapeLayer] = []
     private var currentIndex = 0
     private var lines: [String: [CGPoint]] = [:]
     private var keys = ["head", "fate", "heart", "life"]
     var zoomScale = 3.0

     override func viewDidLoad() {
         super.viewDidLoad()
         
         scrollViewToZoom.delegate = self
         scrollViewToZoom.minimumZoomScale = 1.0
         scrollViewToZoom.showsHorizontalScrollIndicator = false
         scrollViewToZoom.showsVerticalScrollIndicator = false

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
 //            self.scrollViewToZoom.contentSize = self.scrollViewToZoom.frame.size
             self.scrollViewToZoom.setZoomScale(1, animated: false)
             self.scrollViewToZoom.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
         }) { _ in
             
         }
     }
     
     func viewForZooming(in scrollView: UIScrollView) -> UIView? {
         return imageView
     }

     
     // MARK: - Open Image Picker
     func openImagePicker(sourceType: UIImagePickerController.SourceType) {
         let imagePicker = UIImagePickerController()
         imagePicker.delegate = self
         imagePicker.sourceType = sourceType
         present(imagePicker, animated: true)
     }
     
     @IBAction func selectImage(_ sender: UIButton) {
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

         // For iPads: Avoid crash by presenting as popover
         if let popoverController = alertController.popoverPresentationController {
             popoverController.sourceView = sender
             popoverController.sourceRect = sender.bounds
         }

         present(alertController, animated: true)
     }

     
     // MARK: - Image Picker Delegate
     func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
         if let selectedImage = info[.originalImage] as? UIImage {
             self.clearPreviousLines()
             let backgroundRemoval = BackgroundRemoval()
             do {
                 let img = resizeImageKeepingAspectRatio(image: selectedImage)

                 let image = try backgroundRemoval.removeBackground(image: img!)
                 
                 self.zoomScale = self.getAdaptiveZoomScale(for: image.size)
                 imageView.image = image
                 self.zoomImage()
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
                         if tempDict.count > 0{
                             DispatchQueue.main.async {
                                 self.lines["head"] = tempDict["head"] ?? []
                                 self.lines["heart"] = tempDict["heart"] ?? []
                                 self.lines["fate"] = tempDict["fate"] ?? []
                                 self.lines["life"] = tempDict["life"] ?? []
                                 self.currentIndex = 0
                                 self.drawNextLine()
                             }
                         }
                     }
                 }
             } catch {
                 print(error)
             }

         }
         picker.dismiss(animated: true)
     }
     
     func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
         picker.dismiss(animated: true)
     }
     
     func uploadImageToAPI(image: UIImage, completion: @escaping ([String: Any]?, UIImage?) -> Void) {
         let url = URL(string: "http://192.168.1.6:8000/predict/")!//"http://127.0.0.1:8000/predict/"
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

     
     private func drawNextLine() {
         let colors: [UIColor] = [.red, .blue, .yellow, .green]
         var val = ""
         if currentIndex == 0{
             val = "head"
         }else if currentIndex == 1{
             val = "fate"
         }else if currentIndex == 2{
             val = "heart"
         }else if currentIndex == 3{
             val = "life"
         }
         let point = lines[val] ?? []
         if point.count <= 0{
             DispatchQueue.main.async {
                 self.currentIndex += 1
                 if self.currentIndex < self.lines.count {
                     self.drawNextLine()
                 } else {
                     self.resetZoom()
                 }
             }
             return
         }
         let color = colors[currentIndex % colors.count]

         // Get the **start point** instead of the midPoint
         let startPoint = convertPointToImageView(x: point.first!)

         let zoomScale: CGFloat = self.zoomScale
         let targetOffsetX = max(startPoint.x * zoomScale - scrollViewToZoom.bounds.width / 2, 0)
         let targetOffsetY = max(startPoint.y * zoomScale - scrollViewToZoom.bounds.height / 2, 0)

         self.drawLine(points: point, color: color)
         // **Directly Zoom & Move to the Start Point**
 //        UIView.animate(withDuration: 1.2, delay: 0.2, options: [.curveEaseInOut], animations: {
 //            self.scrollViewToZoom.setZoomScale(zoomScale, animated: false)
 //            self.scrollViewToZoom.setContentOffset(CGPoint(x: targetOffsetX, y: targetOffsetY), animated: false)
 //        }) { _ in
 //
 //        }
     }

     private func drawLine(points: [CGPoint], color: UIColor) {
         if points.count <= 0 { return }
         let path = UIBezierPath()
         let firstPoint = points.first!
         path.move(to: firstPoint)

         let imageSize = imageView.image?.size ?? CGSize(width: 640, height: 640) // Default if image size is nil
         let baseSize: CGFloat = 640.0  // Reference image size

         // Scale factor based on the image size relative to the base size
         let scaleFactor = (imageSize.width + imageSize.height) / (2 * baseSize)

         let shapeLayer = CAShapeLayer()
         shapeLayer.strokeColor = color.cgColor
         shapeLayer.fillColor = UIColor.clear.cgColor
         shapeLayer.lineWidth = 2.0 * scaleFactor
         shapeLayer.lineCap = .round
         shapeLayer.lineJoin = .round
         imageView.layer.addSublayer(shapeLayer)
         shapeLayers.append(shapeLayer)

         var animationPath = [CGPoint]()
         for item in points{
             let point = convertPointToImageView(x: item)
             animationPath.append(item)
         }

         animatePathDrawing(shapeLayer: shapeLayer, path: path, points: animationPath)
         if let lastPoint = points.last{
             addLabel(at: lastPoint, text: getLineName(for: currentIndex), color: color)
         }

     }

     private func animatePathDrawing(shapeLayer: CAShapeLayer, path: UIBezierPath, points: [CGPoint]) {
         guard points.count > 1 else { return }

         let animationDuration: TimeInterval = 5.0
         let interval = animationDuration / Double(points.count)

         // Create a full path
         let fullPath = UIBezierPath()
         fullPath.move(to: points.first!)

         for i in 1..<points.count {
             let controlPoint = CGPoint(x: (points[i - 1].x + points[i].x) / 2, y: (points[i - 1].y + points[i].y) / 2)
             fullPath.addQuadCurve(to: points[i], controlPoint: controlPoint)
         }

         shapeLayer.path = fullPath.cgPath

         // Stroke animation
         let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
         strokeAnimation.fromValue = 0.0
         strokeAnimation.toValue = 1.0
         strokeAnimation.duration = animationDuration
         strokeAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
         strokeAnimation.fillMode = .forwards
         strokeAnimation.isRemovedOnCompletion = false  // Ensures the stroke remains

         shapeLayer.add(strokeAnimation, forKey: "strokeAnimation")

         // Smooth scrolling and zooming animation
         UIView.animateKeyframes(withDuration: animationDuration, delay: 0, options: [.calculationModeLinear], animations: {
             for (index, currentPoint) in points.enumerated() {
                 let delay = Double(index) * interval
                 UIView.addKeyframe(withRelativeStartTime: delay / animationDuration, relativeDuration: interval / animationDuration) {
                     let zoomScale: CGFloat = self.zoomScale
                     let targetOffsetX = max(currentPoint.x * zoomScale - self.scrollViewToZoom.bounds.width / 2, 0)
                     let targetOffsetY = max(currentPoint.y * zoomScale - self.scrollViewToZoom.bounds.height / 2, 0)
                     
                     self.scrollViewToZoom.setZoomScale(zoomScale, animated: false)
                     self.scrollViewToZoom.setContentOffset(CGPoint(x: targetOffsetX, y: targetOffsetY), animated: false)
                 }
             }
         }, completion: { _ in
             DispatchQueue.main.async {
                 self.currentIndex += 1
                 if self.currentIndex < self.lines.count {
                     self.drawNextLine()
                 } else {
                     self.resetZoom()
                 }
             }
         })
     }

     func getAdaptiveZoomScale(for imageSize: CGSize) -> CGFloat {
         let screenSize = UIScreen.main.bounds.size
         
         // Calculate scale factor based on image and screen size
         let scaleX = screenSize.width / imageSize.width
         let scaleY = screenSize.height / imageSize.height
         let scale = max(scaleX, scaleY) * 1.5  // Multiply by 1.5 as per your requirement

         scrollViewToZoom.maximumZoomScale = scale

         return scale
     }


     func resetZoom() {
         UIView.animate(withDuration: 0.8) {
             self.zoomImage()
         }
     }


     private func clearPreviousLines() {
         for layer in shapeLayers {
             layer.removeFromSuperlayer()
         }
         
         for subview in imageView.subviews {
             subview.removeFromSuperview()
         }
         shapeLayers.removeAll()
     }
     
     func convertPointToImageView(x: CGPoint) -> CGPoint {
         guard let imageSize = imageView.image?.size else { return x }
         
         let imageViewSize = imageView.bounds.size
         let scaleX = imageViewSize.width / imageSize.width
         let scaleY = imageViewSize.height / imageSize.height
         
         return CGPoint(x: x.x * scaleX, y: x.y * scaleY)
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
     private func addLabel(at point: CGPoint, text: String, color: UIColor) {
         let convertedPoint = convertPointToImageView(x: point)
         let imageSize = imageView.image?.size ?? CGSize(width: 640, height: 640) // Default if image size is nil
         let baseSize: CGFloat = 640.0  // Reference image size

         // Scale factor based on the image size relative to the base size
         let scaleFactor = (imageSize.width + imageSize.height) / (2 * baseSize)

         let label = UILabel()
         label.text = text
         label.textColor = color
         label.font = UIFont.systemFont(ofSize: 12 * scaleFactor)
         label.backgroundColor = UIColor.clear
         label.textAlignment = .center
         label.sizeToFit()
         
         // Adjust position so it does not overlap the line
         label.frame = CGRect(x: convertedPoint.x + 5, y: convertedPoint.y - 20, width: label.frame.width + 10, height: label.frame.height + 5)
         
         imageView.addSubview(label)
     }

 }

 func resizeImageKeepingAspectRatio(image: UIImage, maxDimension: CGFloat = 640) -> UIImage? {
     let originalSize = image.size
     
     // Determine scale factor based on the larger dimension
     let scaleFactor = maxDimension / max(originalSize.width, originalSize.height)
     
     let newSize = CGSize(width: originalSize.width * scaleFactor, height: originalSize.height * scaleFactor)
     let renderer = UIGraphicsImageRenderer(size: newSize)
     
     return renderer.image { _ in
         image.draw(in: CGRect(origin: .zero, size: newSize))
     }
 }

 */
