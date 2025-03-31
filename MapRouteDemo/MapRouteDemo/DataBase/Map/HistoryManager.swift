import Foundation
import UIKit
import CoreLocation


struct LocationRouteModel {
    var id: UUID
    var fromLocation: String
    var toLocation: String
    var imageName: String
}


class LocationRouteManager {
    
    static let shared = LocationRouteManager()
    
    var locationRoutes: [LocationRouteModel] = []
    
    func fetchAllRoutes()->[LocationRouteModel] {
        let fetchedRoutes = DataBaseManager.shared.fetchAllLocationRoutes()
        locationRoutes = fetchedRoutes.map { route in
            LocationRouteModel(id: route.id,
                               fromLocation: route.fromLocation,
                               toLocation: route.toLocation,
                               imageName: route.imageName)
        }
        
        return locationRoutes
    }
    
    func deleteRoute(at index: Int) {
        let routeID = locationRoutes[index].id
        DataBaseManager.shared.deleteLocationRoute(byID: routeID)
        locationRoutes.remove(at: index)
    }
    
    func saveImageToDocuments(image: UIImage) -> String? {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        // Generate a unique file name
        let imageName = "map_snapshot_\(UUID().uuidString).png"
        let fileURL = documentsDirectory.appendingPathComponent(imageName)
        
        // Convert image to PNG data
        if let imageData = image.pngData() {
            do {
                try imageData.write(to: fileURL)
                return imageName  // Return the saved image name
            } catch {
                print("Error saving image: \(error.localizedDescription)")
                return nil
            }
        }
        
        return nil
    }


    func getImageFromDocuments(imageName: String) -> UIImage? {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(imageName)
        if fileManager.fileExists(atPath: fileURL.path) {
            return UIImage(contentsOfFile: fileURL.path)
        }
        
        return nil
    }
}

