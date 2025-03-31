import UIKit
import MapKit

class MapkitViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var drawRouteButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var fromString = ""
    var toString = ""
    var isZoomed = false
    var isFromPlus = false
    var searchItemID : UUID!
    var isFrom = false
    
    private let searchService = LocationSearchService()
    
    private var searchResults: [MKLocalSearchCompletion] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegateSetup()
        fromTextField.text = fromString
        toTextField.text = toString
        drawRouteButton.addTarget(self, action: #selector(handleDrawRoute), for: .touchUpInside)
        
        if !isFromPlus {
            handleDrawRoute()
        }
    }
    
    func delegateSetup(){
        mapView.delegate = self
        fromTextField.delegate = self
        toTextField.delegate = self
        searchService.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @IBAction func saveAndShareImage(_ sender: UIButton) {
        MapManager.shared.captureMapSnapshot(showFullRoute: true, mapView: self.mapView) { [weak self] finalImage in
            guard let self = self, let image = finalImage else { return }

            if let savedImageName = LocationRouteManager.shared.saveImageToDocuments(image: image) {
                let routeID = isFromPlus ? UUID() : searchItemID
                let newRoute = LocationRouteModel(id: routeID!,
                                                  fromLocation: fromTextField.text ?? "",
                                                  toLocation: toTextField.text ?? "",
                                                  imageName: savedImageName)
                
                if isFromPlus {
                    DataBaseManager.shared.addLocationRoute(model: newRoute)
                } else {
                    DataBaseManager.shared.updateLocationRoute(with: newRoute)
                }
                
                openSearchHistory()
            } else {
                print("Failed to save image.")
            }
        }
    }

    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
        self.tableView.isHidden = false
        searchService.updateSearchQuery(newText)
        return true
    }

}
// MARK: - UITableViewDataSource & UITableViewDelegate
extension MapkitViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! SearchCell
        let searchResult = searchResults[indexPath.row]
        
        cell.lblTitle.text = searchResult.title
        cell.lblSubTitle.text = searchResult.subtitle
        cell.lblSubTitle.textColor = .gray
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlace = searchResults[indexPath.row]
        let title = selectedPlace.title
        let subtitle = selectedPlace.subtitle
        if fromTextField.isEditing == true {
            fromTextField.text = "\(title), \(subtitle)"
        }else if toTextField.isEditing == true {
            toTextField.text = "\(title), \(subtitle)"
        }
 
        self.tableView.isHidden = true
    }
}

extension MapkitViewController{
    
    @objc func handleDrawRoute() {
        guard let fromText = fromTextField.text, !fromText.isEmpty,
              let toText = toTextField.text, !toText.isEmpty else {
            showAlert(message: "Please enter both locations.")
            return
        }
        clearMap()
        MapManager.shared.getCoordinates(address: fromText) { [weak self] sourceCoordinate in
            guard let self = self, let sourceCoordinate = sourceCoordinate else {
                self?.showAlert(message: "Could not find starting location.")
                return
            }
            MapManager.shared.getCoordinates(address: toText) { destinationCoordinate in
                guard let destinationCoordinate = destinationCoordinate else {
                    self.showAlert(message: "Could not find destination location.")
                    return
                }
                MapManager.shared.createRoute(from: self.fromTextField.text!, to: self.toTextField.text!, from: sourceCoordinate, to: destinationCoordinate, mapView: self.mapView, from: self)
            }
        }
    }
    
    func clearMap() {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    // Navigate to SearchHistoryVC
    func openSearchHistory() {
        if let historyVC = storyboard?.instantiateViewController(withIdentifier: "SearchHistoryVC") as? SearchHistoryVC {
            historyVC.navigationItem.setHidesBackButton(true, animated: true)
            navigationController?.pushViewController(historyVC, animated: true)
        }
    }

    
    // Save to Photos
    func savePhotosAlbum(image:UIImage){
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
}

// MARK: - Map View Delegate
extension MapkitViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .systemBlue
        renderer.lineWidth = 8.0
        return renderer
    }
    
}

// MARK: - LocationSearchServiceDelegate
extension MapkitViewController: LocationSearchServiceDelegate {
    
    func didUpdateResults(_ results: [MKLocalSearchCompletion]) {
        self.searchResults = results
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
class SearchCell : UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    
}
