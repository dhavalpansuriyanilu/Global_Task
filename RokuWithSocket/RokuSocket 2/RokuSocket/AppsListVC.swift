
import UIKit

class AppsListVC: UIViewController {
    
    @IBOutlet var collectionChannels: UICollectionView!
    var appsList: [Apps] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchApps()
    }
    
    func fetchApps(){
        RokuWebSocketManager.shared.fetchAllApps { apps in
            DispatchQueue.main.async {
                self.appsList = apps
                self.collectionChannels.reloadData()
                self.fetchAppIcons(index: 0)
            }
        }
    }
    
    func fetchAppIcons(index: Int) {
        
        guard index < appsList.count else {
            return
        }
        
        let item = appsList[index]
        RokuWebSocketManager.shared.fetchAppIcons(app: item) { app in
            DispatchQueue.main.async {
                self.appsList[index] = app!
                self.collectionChannels.reloadItems(at: [IndexPath(item: index, section: 0)])
                self.fetchAppIcons(index: index + 1)
            }
        }
    }

    @IBAction func upAction(sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func refreshAction(sender: UIButton){
        ImageManager.shared.deleteDirectory()
        fetchApps()
    }

}


//MARK:- CollectionView Delegate & Datasource
extension AppsListVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return appsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: AppsCollectionCell = collectionChannels.dequeueReusableCell(withReuseIdentifier: "AppsCollectionCell", for: indexPath) as! AppsCollectionCell
        cell.imgAppIcon.image = UIImage(contentsOfFile: appsList[indexPath.item].url?.path ?? "")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        RokuWebSocketManager.shared.openApp(id: appsList[indexPath.item].id ?? "")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = (UIScreen.main.bounds.width - 54)/2
        if UIDevice().userInterfaceIdiom == .pad{
            width = (UIScreen.main.bounds.width - 72)/3
        }
        
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 18, left: 18, bottom: 40, right: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 18
    }
}

class AppsCollectionCell: UICollectionViewCell{
    //MARK:- Outlets
    @IBOutlet var imgAppIcon: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
