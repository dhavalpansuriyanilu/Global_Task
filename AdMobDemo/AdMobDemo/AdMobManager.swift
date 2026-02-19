import GoogleMobileAds

enum InitStatus{
    case notLoaded
    case success
    case failed
    case loading
}

class AdMobManager: NSObject{
    static let shared = AdMobManager()
    
    var isSDKInitSuccess: InitStatus = .notLoaded
    
    private override init() {
        super.init()
    }
    
    func loadAdMobSDK(completion: (() -> ())?){
        if isSDKInitSuccess == .success || isSDKInitSuccess == .loading{
            return
        }
        isSDKInitSuccess = .loading
        MobileAds.shared.start { status in
            let isReady = status.adapterStatusesByClassName.values.allSatisfy {
                $0.state == .ready
            }
            
            if isReady {
                isSDKInitSuccess = .success
//                AdMobInterstitialManager.shared.loadAd()
            }else{
                isSDKInitSuccess = .failed
            }
        }
    }
    
    class AdMobInterstitialAd: NSObject{
        static let shared = AdMobInterstitialAd()
        
        var isAdInitSuccess: InitStatus = .notLoaded
        
        private var interstitialAd: InterstitialAd?
        
        private override init() {
            super.init()
        }
        
        func initInterstitialAd(){
            
        }
        
        func loadInterstitialAd(completion: (() -> ())?){
            
        }
    }
}
