
import UIKit
import FirebaseAnalytics

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        var _param: [String: String] = [:]
        _param["NetworkType"] = "Available"
        _param["LaunchCounter"] = "1"
        print("================================Event Start================================")
        print("Parameters:== \(_param ?? [:])")
        print("================================Event Complete================================")
        Analytics.logEvent("TestEvents", parameters: _param)

    }
}
