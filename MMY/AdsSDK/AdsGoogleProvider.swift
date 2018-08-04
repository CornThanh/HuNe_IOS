//
//  GGFactory.swift
//  SwiftProject1
//
//  Created by Blue R&D on 2/8/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit
import SwiftyJSON
import GoogleMobileAds

class AdsGoogleProvider: AdsProvider, GADBannerViewDelegate, GADNativeExpressAdViewDelegate, GADInterstitialDelegate{
    override init(){
        super.init()
        type = .google
    }
    
    override func addTestId(id: String) {
        if id == "simulator"{
            testIds.append(kGADSimulatorID)
        }else{
            testIds.append(id)
        }
    }

    override func createNewAd(from json:JSON) -> Ads? {        
        guard let adType = AdType(rawValue: json["adType"].stringValue) else{
            return nil
        }
        
        switch adType {
        case .smart: return SmartAds(json: json, delegate: self, testIds: testIds)
        case .normal: return NormalAds(json: json, delegate: self, testIds: testIds)
        case .native: return NativeAds(json: json, delegate: self, testIds: testIds)
        case .interstitial: return InterstitialAds(json: json, delegate: self, testIds: testIds)
        default: return nil
        }
    }
    
    // MARK - Ads Delegate
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        log?.debug(bannerView.adUnitID)
        
        adHandler?(bannerView, true)
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        log?.debug(bannerView.adUnitID)
        
        adHandler?(bannerView, false)
    }
    
    func nativeExpressAdViewDidReceiveAd(_ nativeExpressAdView: GADNativeExpressAdView) {
        log?.debug(nativeExpressAdView.adUnitID)
        
        adHandler?(nativeExpressAdView, true)
    }
    
    func nativeExpressAdView(_ nativeExpressAdView: GADNativeExpressAdView, didFailToReceiveAdWithError error: GADRequestError) {
        log?.debug(nativeExpressAdView.adUnitID)
        
        adHandler?(nativeExpressAdView, false)
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        log?.debug(ad.adUnitID)
        
        adHandler?(ad, true)
    }
    
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        log?.debug(ad.adUnitID)
        
        adHandler?(ad, false)
    }
    
    //MARK - Ad Classes
    class NativeAds: Ads {
        var adView : GADNativeExpressAdView?
        
        override func load(in controller: UIViewController){
            super.load(in: controller)
            
            if adView != nil{
                return
            }
            
            adView = GADNativeExpressAdView(frame: .zero)
            adView?.adSize = GADAdSizeFromCGSize(size ?? CGSize.zero)
            adView?.adUnitID = id
            adView?.rootViewController = controller
            adView?.delegate = delegate as? GADNativeExpressAdViewDelegate
            
            let request = GADRequest()
            request.testDevices = testIds
            adView?.load(request)
        }
        
        override func setSize(size : CGSize){
            super.setSize(size: size)
            adView?.adSize = GADAdSizeFromCGSize(size)
        }
        
        override func show(in view: UIView){
            if let adView = adView{
                view.addSubview(adView)
                adView.snp.makeConstraints({ (make) in
                    make.center.equalTo(view)
                    make.size.equalTo(size ?? .zero)
                })
            }
        }
        
        override func check(with adView: Any?) -> Bool {
            return self.adView != nil && self.adView == (adView as? GADNativeExpressAdView)
        }
    }
    
    class SmartAds: Ads {
        var adView : GADBannerView?
        
        override func load(in controller: UIViewController){
            super.load(in: controller)
            
            if adView != nil{
                return
            }
            
            adView = GADBannerView(frame: .zero)
            adView?.adUnitID = id
            adView?.rootViewController = controller
            adView?.delegate = delegate as? GADBannerViewDelegate;
            checkSmartSize()
            
            let request = GADRequest()
            request.testDevices = testIds
            adView?.load(request)
        }
        
        override func setSmartSize(smartSize : AdsSmartSize){
            super.setSmartSize(smartSize: smartSize)
            checkSmartSize()
        }
        
        override func show(in view: UIView){
            if let adView = adView{
                view.addSubview(adView)
                adView.snp.makeConstraints({ (make) in
                    make.center.equalTo(view)
                })
            }
        }
        
        override func check(with adView: Any?) -> Bool {
            return self.adView != nil && self.adView == (adView as? GADBannerView)
        }
        
        private func checkSmartSize(){
            switch adSmartSize ?? .smartPortrait{
            case .smartPortrait:
                adView?.adSize = kGADAdSizeSmartBannerPortrait
                
            case .smartLandscape:
                adView?.adSize = kGADAdSizeSmartBannerLandscape
            }
        }
    }
    
    class NormalAds: Ads {
        var adView : GADBannerView?
        
        override func load(in controller: UIViewController){
            super.load(in: controller)
            
            if adView != nil{
                return
            }
            
            adView = GADBannerView(frame: .zero)
            adView?.adUnitID = id
            adView?.rootViewController = controller
            adView?.delegate = delegate as? GADBannerViewDelegate;
            adView?.adSize = GADAdSizeFromCGSize(size ?? .zero)
            
            let request = GADRequest()
            request.testDevices = testIds
            adView?.load(request)
        }
        
        override func setSize(size: CGSize){
            super.setSize(size: size)
            adView?.adSize = GADAdSizeFromCGSize(size)
        }
        
        override func show(in view: UIView){
            if let adView = adView{
                view.addSubview(adView)
                adView.snp.makeConstraints({ (make) in
                    make.center.equalTo(view)
                    make.size.equalTo(size ?? .zero)
                })
            }
        }
        
        override func check(with adView: Any?) -> Bool {
            return self.adView != nil && self.adView == (adView as? GADBannerView)
        }
    }
    
    class InterstitialAds: Ads {
        var adView: GADInterstitial?
        
        override func load(in controller: UIViewController) {
            super.load(in: controller)
            
            guard let id = id else {
                return
            }
            
            adView = GADInterstitial(adUnitID: id)
            adView?.delegate = delegate as? GADInterstitialDelegate
            
            let request = GADRequest()
            request.testDevices = testIds
            adView?.load(request)
        }
        
        override func present(in controller: UIViewController){
            guard let view = adView else {
                return
            }
            
            if view.isReady {
                view.present(fromRootViewController: controller)
                load(in: controller)
            }
        }
        
        override func check(with adView: Any?) -> Bool {
            return self.adView != nil && self.adView == (adView as? GADInterstitial)
        }
    }
}
