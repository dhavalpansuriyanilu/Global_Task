import UIKit

extension UIApplication {
    class func finalRootController(_ vcFStick: UIViewController? = UIApplication.shared.connectedScenes
                                    .compactMap { $0 as? UIWindowScene }
                                    .flatMap { $0.windows }
                                    .first(where: { $0.isKeyWindow })?.rootViewController) -> UIViewController? {
        if let navFStick = vcFStick as? UINavigationController {
            return finalRootController(navFStick.visibleViewController)
        }
        if let tabFStick = vcFStick as? UITabBarController {
            if let selectedFStick = tabFStick.selectedViewController {
                return finalRootController(selectedFStick)
            }
        }
        if let presentedFStick = vcFStick?.presentedViewController {
            return finalRootController(presentedFStick)
        }
        
        return vcFStick
    }
}
