
import Foundation
import UIKit

class PalmLineDrawer{
    static var shared = PalmLineDrawer()
    
    func uploadImageToAPI(image: UIImage, completion: @escaping ([String: Any]?, UIImage?) -> Void) {
        guard let url = URL(string: "http://192.168.29.82:8000/predict/") else {
            print("Invalid URL")
            completion(nil, nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            print("Failed to convert image to data")
            completion(nil, nil)
            return
        }
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("❌ Error: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil, nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let keypoints = json["keypoints"] as? [String: Any]
                    if let base64ImageString = json["image_base64"] as? String,
                       let imageData = Data(base64Encoded: base64ImageString),
                       let outputImage = UIImage(data: imageData) {
                        completion(keypoints, outputImage)
                    } else {
                        print("Invalid response data")
                        completion(nil, nil)
                    }
                }
            } catch {
                print("❌ JSON Parsing Error: \(error.localizedDescription)")
                completion(nil, nil)
            }
        }
        
        task.resume()
    }
    
}
