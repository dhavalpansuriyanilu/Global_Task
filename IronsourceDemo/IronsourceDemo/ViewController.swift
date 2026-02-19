
import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var buttonShowRewarded: UIButton?
    @IBOutlet weak var buttonShowInterstitial: UIButton?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        buttonShowRewarded?.isEnabled = false
//        buttonShowInterstitial?.isEnabled = false
////        IronSourceManager.shared.initIronSourceSDK {
////            DispatchQueue.main.async{
                self.buttonShowRewarded?.isEnabled = true
                self.buttonShowInterstitial?.isEnabled = true
//            }
//        }
    }
    
    @IBAction func buttonShowRewardedTapped(_ sender: UIButton){
        IronSourceManager.shared.showRewardedAd {
            print("Init")
        } endAdCompletion: { status in
            print("Successfully showed")
        }
    }
    
    @IBAction func buttonShowInterstitialTapped(_ sender: UIButton){
        IronSourceManager.shared.showInterstitialAd(isFromChartBoostFailed: false, startAdCompletion: {
            print("Init")
        }, endAdCompletion: { status in
            print("Successfully showed interstitial")
        })
    }
}
