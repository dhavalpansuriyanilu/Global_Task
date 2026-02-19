
import UIKit

class ContainerVC: UIViewController {

    @IBOutlet weak var containerView: UIView!
    
    var isAppeared = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        containerView.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !isAppeared{
            isAppeared = true
//            containerView.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height)

            IronSourceManager.shared.initIronSourceSDK {
                IronSourceManager.shared.showBanner(toView: self, contentView: self.containerView)
            }
        }
    }
}
