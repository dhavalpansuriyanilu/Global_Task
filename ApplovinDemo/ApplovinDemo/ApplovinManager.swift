import AppLovinSDK

class ApplovinManager: NSObject{
    static let shared = ApplovinManager()
    static let applovinSDKKey = "05TMDQ5tZabpXQ45_UTbmEGNUtVAzSTzT6KmWQc5_CuWdzccS4DCITZoL3yIWUG3bbq60QC_d4WF28tUC4gVTF"
    static let rewardedUnitId = "rewardTestId"
    static let interstitialUnitId = "interstitialTestId"
    static let isDebugMode = true
    
    private override init() {
        super.init()
    }
    
    func initAppLovinSDK(completion: (() -> ())?){
        // Create the initialization configuration
        let initConfig = ALSdkInitializationConfiguration(sdkKey: ApplovinManager.applovinSDKKey) { builder in
            
            builder.mediationProvider = ALMediationProviderMAX
//            
//            // Enable test mode by default for the current device.
            #if DEBUG
            if ApplovinManager.isDebugMode{
                if let currentIDFV = UIDevice.current.identifierForVendor?.uuidString
                {
                    builder.testDeviceAdvertisingIdentifiers = [currentIDFV]
                }
            }
            #else
             // No debugging information in release build
            #endif
        }

        // Initialize the SDK with the configuration
        ALSdk.shared().initialize(with: initConfig) { sdkConfig in
            DispatchQueue.main.async {
                completion?()
            }
            _ = AppLovinRewardedAd.shared
            _ = ApplovinInterstitialAd.shared
        }
    }
    
    func showInterstitialAd(startAdCompletion:(() -> ())?, endAdCompletion:((Bool) -> ())?){
        ApplovinInterstitialAd.shared.showInterstitialAd(startAdCompletion: startAdCompletion, endAdCompletion: endAdCompletion)
    }
    
    func showRewardedAd(startAdCompletion:(() -> ())?, endAdCompletion:((Bool) -> ())?){
        AppLovinRewardedAd.shared.showRewardedAd(startAdCompletion: startAdCompletion, endAdCompletion: endAdCompletion)
    }
    
    
    //MARK: -===============================================
    //MARK: -Rewarded Ads
    //MARK: -===============================================
    private class AppLovinRewardedAd: NSObject, MARewardedAdDelegate{
        static let shared = AppLovinRewardedAd()
        
        private var rewardedAd: MARewardedAd!

        private var rewardedAdStartCompletion: [(() -> ())?] = []
        private var rewardedAdEndCompletion: [((Bool) -> ())?] = []

        private override init() {
            super.init()
            setupRewardedAds()
        }
        
        private func setupRewardedAds(){
            rewardedAd = MARewardedAd.shared(withAdUnitIdentifier: ApplovinManager.rewardedUnitId)
            rewardedAd.delegate = self
            
            // Load the first ad
            rewardedAd.load()
        }
        
        func showRewardedAd(startAdCompletion:(() -> ())?, endAdCompletion:((Bool) -> ())?){
            if rewardedAd.isReady{
                rewardedAdStartCompletion.append(startAdCompletion)
                rewardedAdEndCompletion.append(endAdCompletion)
                rewardedAd.show()
            }else{
                rewardedAd.load()
                startAdCompletion?()
                endAdCompletion?(false)
            }
        }
        
        //MARK: -Rewarded ads Delegate
        func didLoad(_ ad: MAAd) {
        }
        
        func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError){
            
        }
        
        func didDisplay(_ ad: MAAd) {
            if let completion = rewardedAdStartCompletion.first{
                completion?()
            }
            rewardedAdStartCompletion.removeAll()
        }
        
        func didClick(_ ad: MAAd) {}
        
        func didHide(_ ad: MAAd){
            rewardedAd.load()
        }
        
        func didFail(toDisplay ad: MAAd, withError error: MAError){
            rewardedAd.load()
            if let completion = rewardedAdStartCompletion.first{
                completion?()
            }
            
            if let completion = rewardedAdEndCompletion.first{
                completion?(true)
            }
            rewardedAdStartCompletion.removeAll()
            rewardedAdEndCompletion.removeAll()
            
        }
        
        func didRewardUser(for ad: MAAd, with reward: MAReward){
            // Rewarded ad was displayed and user should receive the reward
            if let completion = rewardedAdStartCompletion.first{
                completion?()
            }
            
            if let completion = rewardedAdEndCompletion.first{
                completion?(true)
            }
            rewardedAdStartCompletion.removeAll()
            rewardedAdEndCompletion.removeAll()
        }
    }



    //MARK: -===============================================
    //MARK: -Interstitial Ads
    //MARK: -===============================================
    private class ApplovinInterstitialAd: NSObject, MAAdDelegate{
        static let shared = ApplovinInterstitialAd()
        
        private var interstitialAd: MAInterstitialAd!
            
        private var interstitialAdStartCompletion: [(() -> ())?] = []
        private var interstitialAdEndCompletion: [((Bool) -> ())?] = []

        private override init() {
            super.init()
            self.setupInterstitialAds()
        }
        
        private func setupInterstitialAds(){
            interstitialAd = MAInterstitialAd(adUnitIdentifier: ApplovinManager.interstitialUnitId)
            interstitialAd.delegate = self
            
            // Load the first ad
            interstitialAd.load()
        }
        
        func showInterstitialAd(startAdCompletion:(() -> ())?, endAdCompletion:((Bool) -> ())?){
            if interstitialAd.isReady{
                interstitialAdStartCompletion.append(startAdCompletion)
                interstitialAdEndCompletion.append(endAdCompletion)
                interstitialAd.show()
            }else{
                interstitialAd.load()
                startAdCompletion?()
                endAdCompletion?(false)
            }
        }
        
        //MARK: -Interstitial ads Delegate
        func didLoad(_ ad: MAAd) {
        }
        
        func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError){
            print(error.debugDescription)
        }
        
        func didDisplay(_ ad: MAAd) {
            if let completion = interstitialAdStartCompletion.first{
                completion?()
            }
            interstitialAdStartCompletion.removeAll()
        }
        
        func didClick(_ ad: MAAd) {}
        
        func didHide(_ ad: MAAd)
        {
            interstitialAd.load()
            if let completion = interstitialAdStartCompletion.first{
                completion?()
            }
            
            if let completion = interstitialAdEndCompletion.first{
                completion?(true)
            }
            interstitialAdStartCompletion.removeAll()
            interstitialAdEndCompletion.removeAll()
        }
        
        func didFail(toDisplay ad: MAAd, withError error: MAError)
        {
            // Interstitial ad failed to display. AppLovin recommends that you load the next ad.
            interstitialAd.load()
            if let completion = interstitialAdStartCompletion.first{
                completion?()
            }
            
            if let completion = interstitialAdEndCompletion.first{
                completion?(true)
            }
            interstitialAdStartCompletion.removeAll()
            interstitialAdEndCompletion.removeAll()
            
        }
    }
}


