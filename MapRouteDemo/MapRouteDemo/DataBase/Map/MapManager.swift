
import Foundation
import MapKit

class MapManager: NSObject {
    static let shared = MapManager()
    
    override init() {
        
    }
    
    func getCoordinates(address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let placemark = placemarks?.first, let location = placemark.location else {
                completion(nil)
                return
            }
            completion(location.coordinate)
        }
    }
    
    func createRoute(from sourceLocationName:String, to destinationLocationName:String,from sourceLocation: CLLocationCoordinate2D, to destinationLocation: CLLocationCoordinate2D, mapView: MKMapView,from controller: UIViewController) {
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let sourceAnnotation = MKPointAnnotation()
        sourceAnnotation.coordinate = sourceLocation
        sourceAnnotation.title = sourceLocationName
        
        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.coordinate = destinationLocation
        destinationAnnotation.title = destinationLocationName
        
        mapView.showAnnotations([sourceAnnotation, destinationAnnotation], animated: true)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { [weak self] response, error in
            guard let self = self, let response = response else {
                if let error = error {
                    self?.showAlert(message: error.localizedDescription, controller: controller)
                    print("Error calculating directions: \(error.localizedDescription)")
                }
                return
            }
            
            if let route = response.routes.first {
                mapView.addOverlay(route.polyline, level: .aboveRoads)
                
                // Use `setVisibleMapRect` to ensure the route fits well on the screen
                let edgePadding = UIEdgeInsets(top: 80, left: 80, bottom: 80, right: 80)
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: edgePadding, animated: true)
            }
        }
    }
    
    func showAlert(message: String,controller:UIViewController) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        controller.present(alert, animated: true)
    }
}
extension MapManager {
    
    func drawRouteOnSnapshot(snapshot: MKMapSnapshotter.Snapshot, mapView: MKMapView) -> UIImage {
        let image = snapshot.image
        UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale)
        
        // Draw the base map image
        image.draw(at: CGPoint.zero)

        // Get the context for drawing
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return image
        }
        
        context.setStrokeColor(UIColor.systemBlue.cgColor)
        context.setLineWidth(5.0)
        context.setLineJoin(.round)

        for overlay in mapView.overlays {
            if let polyline = overlay as? MKPolyline {
                let points = polyline.points()
                let path = UIBezierPath()
                
                for i in 0..<polyline.pointCount {
                    let mapPoint = points[i]
                    let coordinate = mapPoint.coordinate
                    let point = snapshot.point(for: coordinate)
                    
                    if i == 0 {
                        path.move(to: point)
                    } else {
                        path.addLine(to: point)
                    }
                }
                
                UIColor.systemBlue.setStroke()
                path.lineWidth = 5
                path.stroke()
            }
        }

        // Draw annotations (Start and Destination markers)
        for annotation in mapView.annotations {
            let point = snapshot.point(for: annotation.coordinate)
            let pinImage = UIImage(systemName: "mappin.circle.fill")?.withTintColor(.red, renderingMode: .alwaysOriginal)
            pinImage?.draw(in: CGRect(x: point.x - 12, y: point.y - 12, width: 24, height: 24))
        }
        
        // Retrieve the final image
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return finalImage ?? image
    }
    
    func captureMapSnapshot(showFullRoute: Bool, mapView: MKMapView, completion: @escaping (UIImage?) -> Void) {
        guard showFullRoute, let firstRoute = mapView.overlays.first as? MKPolyline else {
            completion(nil)
            return
        }

        let edgePadding = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
        let fullRouteRect = firstRoute.boundingMapRect

        // Smoothly animate to fit the route
        UIView.animate(withDuration: 1.5, animations: {
            mapView.setVisibleMapRect(fullRouteRect, edgePadding: edgePadding, animated: true)
        }) { _ in
            let options = MKMapSnapshotter.Options()
            options.region = mapView.region
            options.size = mapView.frame.size
            options.scale = UIScreen.main.scale

            let snapshotter = MKMapSnapshotter(options: options)
            snapshotter.start { snapshot, error in
                guard let snapshot = snapshot else {
                    print("Snapshot error: \(String(describing: error))")
                    completion(nil)
                    return
                }

                let finalImage = self.drawRouteOnSnapshot(snapshot: snapshot, mapView: mapView)
                completion(finalImage)
            }
        }
    }
}
