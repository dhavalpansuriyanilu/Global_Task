import IronSource

let appKey = "8545d445"
let interstitialAdUnitId = "wmgt0712uuux8ju4"
let bannerAdUnitId = "iep3rxsyp9na3rw8"
let rewardedAdUnitId = "qwouvdrkuwivay5q"

enum AdStatus{
    case notRequested
    case Success
    case inProgress
    case Failed
}
class IronSourceManager: NSObject{
    static let shared = IronSourceManager()
    private var isIronSourceInit: AdStatus = .notRequested
    
    private override init() {
        super.init()
    }
    
    func initIronSourceSDK(completion: (() -> ())?){
//        if IAPStoreKitHandler.shared.hasPurchased || TVCastAccessibilityHandler.status == .ConnectionStatusNotAccessible{
//            completion?()
//            return
//        }
        if isIronSourceInit == .inProgress || isIronSourceInit == .Success{
            completion?()
            return
        }
        
        // Create the initialization configuration
        isIronSourceInit = .inProgress
        
        let requestBuilder = LPMInitRequestBuilder(appKey: appKey)
        let initRequest = requestBuilder.build()
        LevelPlay.initWith(initRequest) { config, error in
            
            guard error == nil else {
                self.isIronSourceInit = .Failed
                completion?()
                return
            }
            self.isIronSourceInit = .Success
            IronSourceInterstitialAd.shared.setupInterstitialAds()
            ironSourceBannerAd.shared.setupBannerAds()
            IronSourceRewardedAd.shared.setupRewardedAds()
            completion?()
        }
    }
    
    func showInterstitialAd(isFromChartBoostFailed: Bool, startAdCompletion:(() -> ())?, endAdCompletion:((Bool) -> ())?){
        if self.isIronSourceInit == .Success{
            IronSourceInterstitialAd.shared.showInterstitialAd(isFromChartBoostFailed: isFromChartBoostFailed, startAdCompletion: startAdCompletion, endAdCompletion: endAdCompletion)
        }else{
            initIronSourceSDK() {}
            startAdCompletion?()
            endAdCompletion?(false)
        }
    }
    
    func showRewardedAd(startAdCompletion:(() -> ())?, endAdCompletion:((Bool) -> ())?){
        if self.isIronSourceInit == .Success{
            IronSourceRewardedAd.shared.showRewardedAd(startAdCompletion: startAdCompletion, endAdCompletion: endAdCompletion)
        }else{
            initIronSourceSDK() {}
            startAdCompletion?()
            endAdCompletion?(false)
        }
    }
    
    //MARK: -===============================================
    //MARK: -Interstitial Ads
    //MARK: -===============================================
    private class IronSourceInterstitialAd: NSObject, LPMInterstitialAdDelegate{
        
        static let shared = IronSourceInterstitialAd()
        private var interstitialAdRequestedStatus: AdStatus = .notRequested
        
        private var interstitialAd: LPMInterstitialAd?
        
        private var interstitialAdStartCompletion: [(() -> ())?] = []
        private var interstitialAdEndCompletion: [((Bool) -> ())?] = []
        
        private override init() {
            super.init()
        }
        
        func setupInterstitialAds(){
//            if IAPStoreKitHandler.shared.hasPurchased{
//                return
//            }
            self.interstitialAd = LPMInterstitialAd(adUnitId: interstitialAdUnitId)
            self.interstitialAd?.setDelegate(self)
            self.loadAd()
        }
        
        func showInterstitialAd(isFromChartBoostFailed: Bool, startAdCompletion:(() -> ())?, endAdCompletion:((Bool) -> ())?){
            if interstitialAd?.isAdReady() ?? false{
                guard let vc = UIApplication.finalRootController() else{
//                    TVCastFirebaseManager.logEvent_AdRequestedEvent(type: "ISViewControllerNotFound")
                    startAdCompletion?()
                    endAdCompletion?(false)
                    return
                }
//                TVCastFirebaseManager.logEvent_AdRequestedEvent(type: isFromChartBoostFailed ? "CBIS" : "IS")
                interstitialAdStartCompletion.append(startAdCompletion)
                interstitialAdEndCompletion.append(endAdCompletion)
                interstitialAd?.showAd(viewController: vc, placementName: nil)
            }else{
                self.loadAd()
                startAdCompletion?()
                endAdCompletion?(false)
            }
        }
        
        func loadAd(){
            if interstitialAdRequestedStatus != .inProgress{
                interstitialAdRequestedStatus = .inProgress
                interstitialAd?.loadAd()
            }
        }
        
        //MARK: -Interstitial ads Delegate
        func didLoadAd(with adInfo: LPMAdInfo) {
            interstitialAdRequestedStatus = .Success
        }
        
        func didDisplayAd(with adInfo: LPMAdInfo) {
            DispatchQueue.main.async {
                if let completion = self.interstitialAdStartCompletion.first{
                    completion?()
                }
                self.interstitialAdStartCompletion.removeAll()
            }
        }
        
        func didFailToLoadAd(withAdUnitId adUnitId: String, error: any Error) {
            interstitialAdRequestedStatus = .Failed
//            TVCastFirebaseManager.logEvent_AdRequestedEventFailed(type: "ISFAILEDLOAD", error: "\(error.localizedDescription)")
        }
        
        func didClickAd(with adInfo: LPMAdInfo) { }
        
        func didCloseAd(with adInfo: LPMAdInfo) {
            self.loadAd()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                IAPStoreKitHandler.shared.triggerBoredAlert() {
//                    DispatchQueue.main.async {
                        if let completion = self.interstitialAdStartCompletion.first{
                            completion?()
                        }
                        
                        if let completion = self.interstitialAdEndCompletion.first{
                            completion?(true)
                        }
                        self.interstitialAdStartCompletion.removeAll()
                        self.interstitialAdEndCompletion.removeAll()
//                    }
//                }
            }
        }
        
        func didFailToDisplayAd(with adInfo: LPMAdInfo, error: any Error) {
//            self.loadAd()
            DispatchQueue.main.async {
                if let completion = self.interstitialAdStartCompletion.first{
                    completion?()
                }
                
                if let completion = self.interstitialAdEndCompletion.first{
                    completion?(false)
                }
                self.interstitialAdStartCompletion.removeAll()
                self.interstitialAdEndCompletion.removeAll()
            }
//            TVCastFirebaseManager.logEvent_AdRequestedEventFailed(type: "ISFAILEDSHOW", error: "\(error.localizedDescription)")
        }
    }
    
    
    //MARK: -===============================================
    //MARK: -Banner Ads
    //MARK: -===============================================
    func showBanner(toView: UIViewController, contentView: UIView){
        ironSourceBannerAd.shared.attachBannerIntoView(toView: toView, contentView: contentView)
        
        if self.isIronSourceInit != .Success{
            initIronSourceSDK() {}
        }
    }
    
    func discardBanner(){
        ironSourceBannerAd.shared.hideBanner()
    }
    
    private class ironSourceBannerAd: NSObject, LPMBannerAdViewDelegate{
        static let shared = ironSourceBannerAd()
        private var ironSourceBannerAdStatus: AdStatus = .notRequested
        private var isBannerAddedOnce = false
        private var ironSourceBannerView: LPMBannerAdView?
        private var adBannerSize: LPMAdSize?
        private var adBaseView: UIView?
        private var adbaseVC: UIViewController?
        
        private override init() {
            super.init()
        }
        
        func setupBannerAds(){
            
            self.adBannerSize = LPMAdSize.createAdaptive()
            
            guard let bannerS = adBannerSize else {
                ironSourceBannerAdStatus = .Failed
                return
            }
            ironSourceBannerAdStatus = .inProgress
            
            //  Create the banner ad view object with required & optional params
            
            let adConfiguration = LPMBannerAdViewConfigBuilder()
                .set(adSize: bannerS)
                .set(placementName: "placementName")
                .build()
            
            // Create the banner view and set the ad unit id
            
            
            self.ironSourceBannerView = LPMBannerAdView(adUnitId: bannerAdUnitId, config: adConfiguration)
            
            self.ironSourceBannerView?.setDelegate(self)
            
            
        }
        
        func attachBannerIntoView(toView: UIViewController, contentView: UIView) {
            
            if IronSourceManager.shared.isIronSourceInit != .Success{
                NSLayoutConstraint.deactivate(
                    contentView.superview?.constraints.filter {
                        (($0.firstItem as? UIView) == contentView && $0.firstAttribute == .bottom)
                        || (($0.secondItem as? UIView) == contentView && $0.secondAttribute == .bottom)
                    } ?? []
                )

                // Pin contentView above banner (example: 50 pts above safe area bottom)
                
                let contentBottomConstraint = contentView.bottomAnchor.constraint(
                    equalTo: toView.view.safeAreaLayoutGuide.bottomAnchor,
                    constant: -60 // negative because you want it above
                )
                contentBottomConstraint.isActive = true
                return
            }
            
            //DispatchQueue.main.asyncAfter(wallDeadline: .now() + 5) {
            if IronSourceManager.shared.isIronSourceInit == .Success && self.ironSourceBannerAdStatus != .Success{
                    self.adbaseVC = toView
                    self.adBaseView = contentView
                    self.ironSourceBannerView?.loadAd(with: toView)
                } else {
                    IronSourceManager.shared.initIronSourceSDK() {}
                }
            //}
        }
        
        
        func hideBanner() {
            if ironSourceBannerAdStatus == .Success {
                ironSourceBannerView?.destroy()
            }
            DispatchQueue.main.async {
                guard let banner = self.ironSourceBannerView else { return }
                
                // Remove banner from hierarchy
                banner.removeFromSuperview()
                self.ironSourceBannerView = nil
                self.isBannerAddedOnce = false
                
                // Remove existing bottom constraint on contentView (if pinned to banner)
                if let bottomConstraint = self.adBaseView?.constraints.first(where: {
                    ($0.firstAnchor == self.adBaseView?.bottomAnchor || $0.secondAnchor == self.adBaseView?.bottomAnchor)
                }) {
                    bottomConstraint.isActive = false
                }
                
                // Restore contentView bottom to safe area
                if let vc = self.adbaseVC {
                    // Pin to view controller's safe area
                    let contentBottom = self.adBaseView?.bottomAnchor.constraint(
                        equalTo: vc.view.bottomAnchor
                    )
                    contentBottom?.isActive = true
                    
                } else if let superview = self.adBaseView?.superview {
                    // Fallback: pin to superview bottom (0)
                    let contentBottom = self.adBaseView?.bottomAnchor.constraint(
                        equalTo: superview.bottomAnchor
                    )
                    contentBottom?.isActive = true
                    
                }
            }
        }
        
        
        //MARK: -Banner ads Delegate
        func didLoadAd(with adInfo: LPMAdInfo) {
            ironSourceBannerAdStatus = .Success
            if isBannerAddedOnce {
                return
            }
            DispatchQueue.main.async {
                guard let ADBanner = self.ironSourceBannerView else { return }
                guard let viewCtr = self.adbaseVC else { return }
                guard let viewContent = self.adBaseView else { return }
                self.isBannerAddedOnce = true
                let bannerHeight = self.adBannerSize?.height ?? 50
                let bannerWidth = self.adBannerSize?.width ?? Int(UIScreen.main.bounds.width)
                
                ADBanner.translatesAutoresizingMaskIntoConstraints = false
                viewCtr.view.addSubview(ADBanner)
                
                NSLayoutConstraint.deactivate(
                    self.adBaseView?.superview?.constraints.filter {
                        ($0.firstItem as? UIView) == self.adBaseView && $0.firstAttribute == .bottom
                        || ($0.secondItem as? UIView) == self.adBaseView && $0.secondAttribute == .bottom
                    } ?? []
                )
                
                
                // Pin contentView above banner
                let contentBottom = viewContent.bottomAnchor.constraint(equalTo: ADBanner.topAnchor, constant: -10)
                
                
                // Banner constraints
                
                let centerX = ADBanner.centerXAnchor.constraint(equalTo: viewCtr.view.centerXAnchor)
                let bottom = ADBanner.bottomAnchor.constraint(equalTo: viewCtr.view.safeAreaLayoutGuide.bottomAnchor)
                let width = ADBanner.widthAnchor.constraint(equalToConstant: CGFloat(bannerWidth))
                let height = ADBanner.heightAnchor.constraint(equalToConstant: CGFloat(bannerHeight))
                NSLayoutConstraint.activate([contentBottom, centerX, bottom, width, height])
            }
        }
        
        func didFailToLoadAd(withAdUnitId adUnitId: String, error: any Error) {
            print(error.localizedDescription)
           
//            FirebaseHandler.logEventFailtoLoadAD(strType: "ISBANNER", ErrorMessage: "\(error.localizedDescription)")
        }
    }
    
    //MARK: -===============================================
    //MARK: -Rewarded Ads
    //MARK: -===============================================
    private class IronSourceRewardedAd: NSObject, LPMRewardedAdDelegate{
        static let shared = IronSourceRewardedAd()
        private var rewardedAdRequestedStatus: AdStatus = .notRequested
        var rewardedAd: LPMRewardedAd! = nil
        var reward: LPMReward! = nil
        private var rewardedAdStartCompletion: [(() -> ())?] = []
        private var rewardedAdEndCompletion: [((Bool) -> ())?] = []

        private override init() {
            super.init()
        }
        
        func setupRewardedAds(){
            self.rewardedAd = LPMRewardedAd(adUnitId: rewardedAdUnitId)
            self.rewardedAd.setDelegate(self)
            self.loadAd()
        }
        
        func showRewardedAd(startAdCompletion:(() -> ())?, endAdCompletion:((Bool) -> ())?){
            if rewardedAd?.isAdReady() ?? false{
                guard let vc = UIApplication.finalRootController() else{
//                    TVCastFirebaseManager.logEvent_AdRequestedEvent(type: "ISViewControllerNotFound")
                    startAdCompletion?()
                    endAdCompletion?(false)
                    return
                }
//                TVCastFirebaseManager.logEvent_AdRequestedEvent(type: isFromChartBoostFailed ? "CBIS" : "IS")
                rewardedAdStartCompletion.append(startAdCompletion)
                rewardedAdEndCompletion.append(endAdCompletion)
                self.rewardedAd.showAd(viewController: vc, placementName: nil)
            }else{
                self.loadAd()
                startAdCompletion?()
                endAdCompletion?(false)
            }
        }
        
        func loadAd(){
            if rewardedAdRequestedStatus != .inProgress{
                rewardedAdRequestedStatus = .inProgress
                rewardedAd?.loadAd()
            }
        }
        
        //MARK: -Rewarded Ad Delegate
        func didLoadAd(with adInfo: LPMAdInfo) {
            rewardedAdRequestedStatus = .Success
        }
        
        func didFailToLoadAd(withAdUnitId adUnitId: String, error: any Error) {
            rewardedAdRequestedStatus = .Failed
        }
        
        func didDisplayAd(with adInfo: LPMAdInfo) {
            DispatchQueue.main.async {
                if let completion = self.rewardedAdStartCompletion.first{
                    completion?()
                }
                self.rewardedAdStartCompletion.removeAll()
            }
        }
        
        func didRewardAd(with adInfo: LPMAdInfo, reward: LPMReward) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                if let completion = self.rewardedAdStartCompletion.first{
                    completion?()
                }
                
                if let completion = self.rewardedAdEndCompletion.first{
                    completion?(true)
                }
                self.rewardedAdStartCompletion.removeAll()
                self.rewardedAdEndCompletion.removeAll()
            }
        }
        
        func didCloseAd(with adInfo: LPMAdInfo) {
            self.loadAd()
        }
        
        func didFailToDisplayAd(with adInfo: LPMAdInfo, error: any Error) {
//            self.loadAd()
            DispatchQueue.main.async {
                if let completion = self.rewardedAdStartCompletion.first{
                    completion?()
                }
                
                if let completion = self.rewardedAdEndCompletion.first{
                    completion?(false)
                }
                self.rewardedAdStartCompletion.removeAll()
                self.rewardedAdEndCompletion.removeAll()
            }
//            TVCastFirebaseManager.logEvent_AdRequestedEventFailed(type: "ISFAILEDSHOW", error: "\(error.localizedDescription)")
        }
    }
}
