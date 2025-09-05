import IronSource
import ChartboostSDK
import PKHUD
import Foundation
import UIKit
import SystemConfiguration


class AppConfigurable{
    static let IronSourceAppKey = "8545d445"
    static let IronSourceBannerAdKey = "iep3rxsyp9na3rw8"
    static let IronSourceInterstitialAdKey = "wmgt0712uuux8ju4"
    
    static let chartBoostAppIdentifier = "6566d5dadf86002ccbed16d6"
    static let chartBoostAppSignature = "4aebda11a16551bcf910f512dad85cf61257e6d0"

    static let showInterstitialAdOnCount = 5
    static let isLogEnabled = true
}


class ISCBManager: NSObject{
    static let shared = ISCBManager()
    
    private var isISInitSuccessfully = false
    private var ironSourceInterstitialAd: LPMInterstitialAd! = nil
    private var ironSourceBannerAdView: LPMBannerAdView! = nil
    private var ironSourceBannerSize: LPMAdSize! = nil
    private var rootViewController: UIViewController!
    private var AdStartCompletionsArray:[(()->())] = []
    private var AdCompletionsArray:[(()->())] = []
    private var interstitialAdShownCounter = 0
    
    
    private var chartBoostInterstitial : CHBInterstitial?
    private var isCharBoostInitSuccessfully = false
    
    override init() {
        super.init()
    }
    
    func setupAds(){
        initIronSourceAds { _ in }
        initChartBoostAds{ _ in }
    }
    
    private func initIronSourceAds(completion: ((Bool) -> ())?){
        if !InternetConnectionManager.isConnectedToNetwork(){
            completion?(false)
            return
        }
        if !isISInitSuccessfully{
            Logs.printLog(message: "Init Ironsource SDK")
            let requestBuilder = LPMInitRequestBuilder(appKey: AppConfigurable.IronSourceAppKey)
                .withLegacyAdFormats([IS_INTERSTITIAL, IS_BANNER])
            let initRequest = requestBuilder.build()
            LevelPlay.initWith(initRequest)
            
            { config, error in
                
                guard error == nil else {
                    self.isISInitSuccessfully = false
                    Logs.printLog(type: .Critical, message: "IronSource sdk initialization failed, error =\(error?.localizedDescription ?? "unknown error")")
                    completion?(false)
                    return
                }
                self.isISInitSuccessfully = true
                Logs.printLog(message: "IronSource sdk initialization succeeded")
                self.createInterstititalAd()
                self.createBannerAd()
                completion?(true)
            }
        }else{
            completion?(true)
        }
    }
    
    private func initChartBoostAds(completion: ((Bool) -> ())?){
        if !InternetConnectionManager.isConnectedToNetwork(){
            completion?(false)
            return
        }
        if !isCharBoostInitSuccessfully{
            Chartboost.start(withAppID: AppConfigurable.chartBoostAppIdentifier, appSignature: AppConfigurable.chartBoostAppSignature) { (status) in
                if((status) == nil){
                    self.isCharBoostInitSuccessfully = true
                    self.chartBoostInterstitial = CHBInterstitial(location: "default", delegate: self) //CHBInterstitial(location: CBLocationDefault, delegate: shared)
                    self.chartBoostInterstitial?.cache()
                    completion?(true)
                }else{
                    self.isCharBoostInitSuccessfully = false
                    completion?(false)
                }
            }
        }else{
            completion?(true)
        }
    }
    
    func displayAd(toView: UIViewController, startCompletion:(()->())?, endCompletion:(()->())?){
        if !InternetConnectionManager.isConnectedToNetwork(){
            endCompletion?()
            return
        }
        rootViewController = toView
        interstitialAdShownCounter += 1
        if interstitialAdShownCounter%AppConfigurable.showInterstitialAdOnCount == 0{
            LoaderManager.displayLoader()
            if let startCompletion = startCompletion{
                self.AdStartCompletionsArray.append(startCompletion)
            }
            if let endCompletion = endCompletion{
                self.AdCompletionsArray.append(endCompletion)
            }
            if interstitialAdShownCounter%2 == 0{
                showChartBoostInterstetialAd(toView: toView) {
                    self.showIronSourceInterstetialAd(toView: toView) {
                        self.removeCompletions(removeStart: true, removeEnd: true)
                    }
                }
            }else{
                showIronSourceInterstetialAd(toView: toView) {
                    self.showChartBoostInterstetialAd(toView: toView) {
                        self.removeCompletions(removeStart: true, removeEnd: true)
                    }
                }
            }
        }else{
            endCompletion?()
        }
    }
}

//MARK: - Interstitial
extension ISCBManager{
    private func createInterstititalAd() {
        self.ironSourceInterstitialAd = LPMInterstitialAd(adUnitId: AppConfigurable.IronSourceInterstitialAdKey)
        self.ironSourceInterstitialAd.setDelegate(self)
        self.loadInterstitial()
    }
    
    private func loadInterstitial(){
        if isISInitSuccessfully{
            if self.ironSourceInterstitialAd != nil{
                self.ironSourceInterstitialAd.loadAd()
            }
        }else{
            initIronSourceAds { _ in }
        }
    }
    
    func showIronSourceInterstetialAd(toView: UIViewController, failedCompletion:(()->())?){
        if isISInitSuccessfully{
            if self.ironSourceInterstitialAd != nil{
                if self.ironSourceInterstitialAd.isAdReady(){
                    self.ironSourceInterstitialAd.showAd(viewController: toView, placementName: nil)
                    return
                }
            }
            self.loadInterstitial()
            failedCompletion?()
        }else{
            failedCompletion?()
            initIronSourceAds { _ in }
        }
    }
    
    func showChartBoostInterstetialAd(toView: UIViewController, failedCompletion:(()->())?){
        initChartBoostAds { status in
            if status{
                if self.chartBoostInterstitial?.isCached ?? false{
                    self.chartBoostInterstitial?.show(from: self.rootViewController)
                }else{
                    self.chartBoostInterstitial?.cache()
                    self.removeCompletions(removeStart: true, removeEnd: true)
                }
            }else{
                failedCompletion?()
            }
        }
    }
}

//MARK: - Banners
extension ISCBManager{
    private func createBannerAd() {
        // choose banner size
        // 1. recommended - Adaptive ad size that adjusts to the screen width
        self.ironSourceBannerSize = LPMAdSize.createAdaptive()
        
        guard let bannerSize = ironSourceBannerSize else {
            Logs.printLog(type: .Error, message: "Error creating IronSource banner size")
            return
        }
        
        //  Create the banner ad view object with required & optional params
        self.ironSourceBannerAdView = LPMBannerAdView(adUnitId: AppConfigurable.IronSourceBannerAdKey)
        self.ironSourceBannerAdView.setAdSize(bannerSize)
        
        self.ironSourceBannerAdView.setDelegate(self)
    }
    
    func addBannerToView(toView: UIViewController) {
        initIronSourceAds { status in
            if status{
                DispatchQueue.main.async {
                    self.ironSourceBannerAdView.translatesAutoresizingMaskIntoConstraints = false
                    toView.view.addSubview(self.ironSourceBannerAdView)
                    
                    let centerX = self.ironSourceBannerAdView.centerXAnchor.constraint(equalTo: toView.view.centerXAnchor)
                    let bottom = self.ironSourceBannerAdView.bottomAnchor.constraint(equalTo: toView.view.safeAreaLayoutGuide.bottomAnchor)
                    let width = self.ironSourceBannerAdView.widthAnchor.constraint(equalToConstant: CGFloat(self.ironSourceBannerSize.width))
                    let height = self.ironSourceBannerAdView.heightAnchor.constraint(equalToConstant: CGFloat(self.ironSourceBannerSize.height))
                    NSLayoutConstraint.activate([centerX, bottom, width, height])
                }
                self.ironSourceBannerAdView.loadAd(with: toView)
            }
        }
    }
}

extension ISCBManager: LPMInterstitialAdDelegate, LPMBannerAdViewDelegate {
    func didLoadAd(with adInfo: LPMAdInfo) {
    }
    
    func didFailToLoadAd(withAdUnitId adUnitId: String, error: Error) {
        Logs.printLog(type: .Error, message: "\(#function) error = \(String(describing:error.self))")
    }
    
    func didChangeAdInfo(_ adInfo: LPMAdInfo) {
    }
    
    func didDisplayAd(with adInfo: LPMAdInfo) {
        if adInfo.adUnitId == AppConfigurable.IronSourceInterstitialAdKey{
            self.removeCompletions(removeStart: true, removeEnd: false)
        }
    }
    
    func didFailToDisplayAd(with adInfo: LPMAdInfo, error: Error) {
        if adInfo.adUnitId == AppConfigurable.IronSourceInterstitialAdKey{
            if chartBoostInterstitial?.isCached ?? false{
                chartBoostInterstitial?.show(from: rootViewController)
            }else{
                self.chartBoostInterstitial?.cache()
                self.removeCompletions(removeStart: true, removeEnd: true)
            }
            self.loadInterstitial()
        }
        Logs.printLog(type: .Error, message: "\(#function) error = \(String(describing:error.self)) | adInfo =  \(String(describing:adInfo.self))")
    }
    
    func didClickAd(with adInfo: LPMAdInfo) {
    }
    
    func didCloseAd(with adInfo: LPMAdInfo) {
        if adInfo.adUnitId == AppConfigurable.IronSourceInterstitialAdKey{
            self.loadInterstitial()
            self.removeCompletions(removeStart: false, removeEnd: true)
        }
    }
    
    private func removeCompletions(removeStart: Bool, removeEnd: Bool){
        if removeStart{
            if let adStartCompletion = self.AdStartCompletionsArray.first{
                adStartCompletion()
                self.AdStartCompletionsArray.Remove_Safely(safeAt: 0)
            }
        }
        
        if removeEnd{
            if let adCompletion = self.AdCompletionsArray.first{
                adCompletion()
                self.AdCompletionsArray.Remove_Safely(safeAt: 0)
            }
        }
        
        LoaderManager.dismissLoader()
    }
}

extension ISCBManager: CHBInterstitialDelegate{
    func didCacheAd(_ event: CHBCacheEvent, error: CacheError?) {
    }
    
    func didShowAd(_ event: CHBShowEvent, error: ShowError?) {
        DispatchQueue.main.async {
            if(error != nil){
                guard let ad = self.ironSourceInterstitialAd else{
                    self.removeCompletions(removeStart: true, removeEnd: true)
                    return
                }
                if ad.isAdReady(){
                    ad.showAd(viewController: self.rootViewController, placementName: nil)
                }else{
                    self.removeCompletions(removeStart: true, removeEnd: true)
                }
            }else{
                self.removeCompletions(removeStart: true, removeEnd: false)
            }
        }
    }
    
    func didDismissAd(_ event: CHBDismissEvent) {
        DispatchQueue.main.async {
            self.removeCompletions(removeStart: true, removeEnd: true)
            self.chartBoostInterstitial?.cache()
        }
    }
}


extension Array {
    mutating func Remove_Safely(safeAt index: Int) {
        guard index >= 0 && index < count else {
            print("Index out of bounds while deleting item at index \(index) in \(self). This action is ignored.")
            return
        }
        remove(at: index)
    }
    
    private mutating func insertSafely(_ element: Element, safeAt index: Int) {
        guard index >= 0 && index <= count else {
            print("Index out of bounds while inserting item at index \(index) in \(self). This action is ignored")
            return
        }
        
        insert(element, at: index)
    }
    
    subscript (safe index: Int) -> Element? {
        get {
            return indices.contains(index) ? self[index] : nil
        }
        set {
            Remove_Safely(safeAt: index)
            
            if let element = newValue {
                insertSafely(element, safeAt: index)
            }
        }
    }
    
    func rightRotate(_ amount: Int = 1) -> [Element]? {
        var amount = amount
        if(!(-count...count ~= amount)){
            return nil
        }
        if amount < 0 { amount += count }  // this needs to be >= 0
        return Array(self[amount ..< count] + self[0 ..< amount])
    }
}




class LoaderManager {
    static func displayLoader(text:String? = nil){
        DispatchQueue.main.async {
            if(text == nil){
                HUD.show(.progress)
            }else{
                HUD.show(.label(text))
            }
        }
    }
    
    static func dismissLoader(title:String? = nil, subtitle:String? = nil, isSuccess:Bool = false, duration:TimeInterval = 2.0){
        DispatchQueue.main.async {
            HUD.hide()
        }
    }
}

public class InternetConnectionManager {
    
    
    private init() {
        
    }
    
    public static func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                
                SCNetworkReachabilityCreateWithAddress(nil, $0)
                
            }
            
        }) else {
            
            return false
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
}
