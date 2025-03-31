import UIKit

class SearchHistoryVC: UIViewController {
    @IBOutlet weak var historyTableView: UITableView!
    
    var searchHistoryData: [LocationRouteModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
              
        loadHistoryData()
    }
    
    func loadHistoryData() {
        searchHistoryData = LocationRouteManager.shared.fetchAllRoutes()
        historyTableView.reloadData()
    }
    
    @IBAction func searchNewLocation(_ sender: UIButton) {
        navigateToMapVC(isFromPlus: true)
    }

    func navigateToMapVC(isFromPlus: Bool, data: LocationRouteModel? = nil) {
        if let mapVC = storyboard?.instantiateViewController(withIdentifier: "MapkitViewController") as? MapkitViewController {
            mapVC.isFromPlus = isFromPlus
            if let data = data {
                mapVC.fromString = data.fromLocation
                mapVC.toString = data.toLocation
                mapVC.searchItemID = data.id
            }
            navigationController?.pushViewController(mapVC, animated: true)
        }
    }

    
    func openMap(data: LocationRouteModel) {
        navigateToMapVC(isFromPlus: false, data: data)
    }

}

extension SearchHistoryVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchHistoryData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = historyTableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! HistoryCell
        let searchItem = searchHistoryData[indexPath.row]
        cell.selectionStyle = .none
        cell.fromLocationLbl.text = searchItem.fromLocation
        cell.toLocationLbl.text = searchItem.toLocation
        cell.routeImageView.image = LocationRouteManager.shared.getImageFromDocuments(imageName: searchItem.imageName)
        cell.viewBg.layer.borderWidth = 1
        cell.viewBg.layer.borderColor = UIColor.gray.cgColor
        cell.viewBg.layer.cornerRadius = 10
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = searchHistoryData[indexPath.row]
        openMap(data: data)
    }
    // ✅ Set row height (customize as needed)
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150  // Adjust the height as per your design
    }
}
// MARK: - Delete Route Logic 
extension SearchHistoryVC {
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completionHandler in
            self?.showDeleteConfirmation(for: indexPath, in: tableView, completion: completionHandler)
        }
        deleteAction.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    // MARK: - Helper Function
    private func showDeleteConfirmation(for indexPath: IndexPath, in tableView: UITableView, completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: "Delete Route",
                                      message: "Are you sure you want to delete this route?",
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completion(false)
        })
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteRoute(at: indexPath, in: tableView)
            completion(true)
        })
        
        present(alert, animated: true)
    }

    
    private func deleteRoute(at indexPath: IndexPath, in tableView: UITableView) {
        LocationRouteManager.shared.deleteRoute(at: indexPath.row)
        searchHistoryData.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }

}

class HistoryCell: UITableViewCell {
    @IBOutlet weak var viewBg: UIView!
    @IBOutlet weak var fromLocationLbl: UILabel!
    @IBOutlet weak var toLocationLbl: UILabel!
    @IBOutlet weak var routeImageView: UIImageView! 
}
