//
//  FBFactory.swift
//  SwiftProject1
//
//  Created by Blue R&D on 2/8/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit
import SwiftyJSON
//import FBAudienceNetwork


class AdsFacebookProvider: AdsProvider, FBAdViewDelegate, FBInterstitialAdDelegate, FBNativeAdDelegate{
    override init(){
        super.init()
        type = .facebook
        FBAdSettings.setLogLevel(.log)
    }
    
    override func addTestId(id: String) {
        FBAdSettings.addTestDevice(id)
    }
    
    override func createNewAd(from json:JSON) -> Ads? {
        guard let adType = AdType(rawValue: json["adType"].stringValue) else{
            return nil
        }
        
        switch adType {
        case .normal: return NormalAds(json: json, delegate: self)
        case .native: return NativeAds(json: json, delegate: self)
        case .customNative: return CustomNativeAds(json: json, delegate: self)
        case .interstitial: return InterstitialAds(json: json, delegate: self)
        default: return nil
        }
    }
    
    //MARK - Ads Delegate
    func adViewDidLoad(_ adView: FBAdView) {
        log?.debug(adView.placementID)
        
        adHandler?(adView, true)
    }
    
    func adView(_ adView: FBAdView, didFailWithError error: Error) {
        log?.debug(adView.placementID)
        
        adHandler?(adView, false)
    }
    
    func nativeAdDidLoad(_ nativeAd: FBNativeAd) {
        log?.debug(nativeAd.placementID)
        
        adHandler?(nativeAd, true)
    }
    
    func nativeAd(_ nativeAd: FBNativeAd, didFailWithError error: Error) {
        log?.debug(nativeAd.placementID)
        
        adHandler?(nativeAd, false)
    }
    
    func interstitialAdDidLoad(_ interstitialAd: FBInterstitialAd) {
        log?.debug(interstitialAd.placementID)
        
        adHandler?(interstitialAd, true)
    }
    
    func interstitialAd(_ interstitialAd: FBInterstitialAd, didFailWithError error: Error) {
        log?.debug(interstitialAd.placementID)
        
        adHandler?(interstitialAd, false)
    }

    //MARK - Ad Classes
    class NormalAds: Ads {
        var adView : FBAdView?
        
        override func load(in controller: UIViewController){
            super.load(in: controller)
            
            guard let id = id, let size = size, adView == nil else {
                return
            }
            
            var fbAdSize : FBAdSize?
            
            if size.width == 0 && size.height == 50{
                fbAdSize = kFBAdSizeHeight50Banner
            }else if size.width == 0 && size.height == 90{
                fbAdSize = kFBAdSizeHeight90Banner
            }else if size.width == 0 && size.height == 250{
                fbAdSize = kFBAdSizeHeight250Rectangle
            }
            
            if let fbAdSize = fbAdSize{
                adView = FBAdView(placementID: id, adSize: fbAdSize, rootViewController: controller)
                adView?.delegate = delegate as? FBAdViewDelegate;
                
                adView?.loadAd()
            }
        }
        
        override func show(in view: UIView){
            if let adView = adView{
                view.addSubview(adView)
                adView.snp.makeConstraints({ (make) in
                    make.center.equalTo(view)
                    make.width.equalTo(view)
                    make.height.equalTo(size?.height ?? 0)
                })
            }
        }
        
        override func check(with adView: Any?) -> Bool {
            return self.adView != nil && self.adView == (adView as? FBAdView)
        }
        
    }
    
    class NativeAds: Ads {
        var adView : FBNativeAdView?
        var ad : FBNativeAd?
        
        override func load(in controller: UIViewController){
            super.load(in: controller)
            
            guard let id = id, ad == nil else {
                return
            }
            
            ad = FBNativeAd(placementID: id)
            ad?.delegate = delegate as? FBNativeAdDelegate
            ad?.mediaCachePolicy = FBNativeAdsCachePolicy.all
        
            ad?.load()
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
            guard let ad = adView as? FBNativeAd else {
                return false
            }
            
            if ad == self.ad{
                self.adView?.removeFromSuperview()
                self.adView = FBNativeAdView(nativeAd: ad, with: FBNativeAdViewType.genericHeight100)
                self.adView?.frame = CGRect(origin: CGPoint.zero, size: size ?? CGSize.zero)
                
                if let adView = self.adView{
                    ad.registerView(forInteraction: adView, with: self.controller)
                }
                
                return true
            }
            
            return false
        }

    }
    
    class CustomNativeAds: Ads{
        var adView : CustomNativeAdView?
        var ad : FBNativeAd?
        
        override func load(in controller: UIViewController){
            super.load(in: controller)
            
            guard let id = id, ad == nil else {
                return
            }
            
            ad = FBNativeAd(placementID: id)
            ad?.delegate = delegate as? FBNativeAdDelegate
            ad?.mediaCachePolicy = FBNativeAdsCachePolicy.all
            adView = adView ?? CustomNativeAdView(frame: CGRect(origin: CGPoint.zero, size: size ?? CGSize.zero))
            
            ad?.load()
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
            guard let ad = adView as? FBNativeAd, ad == self.ad else {
                return false
            }
            
            self.adView?.adCoverMediaView.nativeAd = ad
            
            ad.icon?.loadAsync(block: { (image) in
                self.adView?.adIconImageView.image = image
            })
            
            self.adView?.adTitleLabel.text = ad.title
            self.adView?.adBodyView.text = ad.body
            self.adView?.adSocialContext.text = ad.socialContext
            self.adView?.sponsoredLabel.text = "Sponsored"
            self.adView?.adCallToActionButton.setTitle(ad.callToAction, for: UIControlState.normal)
            self.adView?.adChoiceView.nativeAd = ad
            self.adView?.adChoiceView.corner = UIRectCorner.topRight
            
            if let adView = self.adView{
                ad.registerView(forInteraction: adView, with: self.controller)
            }

            return true
        }
        
        class CustomNativeAdView: UIView{
            let adIconImageViewWidth = 50
            let adIconImageViewHeight = 50
            
            let adTitleLableWidth = 0
            let adTitleLableHeight = 0
            
            let adCoverMediaViewWidth = 0
            let adCoverMediaViewHeight = 0
            
            let adSocialContextWidth = 100
            let adSocialContextHeight = 30
            
            let adCallToActionButtonWidth = 50
            let adCallToActionButtonHeight = 30
            
            let adChoiceViewWidth = 50
            let adChoiceViewHeight = 30
            
            let adBodyViewWidth = 100
            let adBodyViewHeight = 60
            
            let adSponsoredLabelWidth = 100
            let adSponsoredLabelHeight = 30
            
            var adIconImageView: UIImageView
            var adTitleLabel: UILabel
            var adCoverMediaView: FBMediaView
            var adSocialContext: UILabel
            var adCallToActionButton: UIButton
            var adChoiceView: FBAdChoicesView
            var adBodyView: UILabel
            var sponsoredLabel: UILabel
            
            override init(frame: CGRect) {
                adIconImageView = UIImageView(frame: CGRect.zero)
                adTitleLabel = UILabel(frame: CGRect.zero)
                adCoverMediaView = FBMediaView(frame: CGRect.zero)
                adSocialContext = UILabel(frame: CGRect.zero)
                adCallToActionButton = UIButton(frame: CGRect.zero)
                adChoiceView = FBAdChoicesView(frame: CGRect.zero)
                adBodyView = UILabel(frame: CGRect.zero)
                sponsoredLabel = UILabel(frame: CGRect.zero)
                
                adCallToActionButton.backgroundColor = UIColor.blue
                
                super.init(frame: frame)
                self.clipsToBounds = true
                
                self.addSubview(adIconImageView)
                self.addSubview(adTitleLabel)
                self.addSubview(adCoverMediaView)
                self.addSubview(adSocialContext)
                self.addSubview(adCallToActionButton)
                self.addSubview(adChoiceView)
                self.addSubview(adBodyView)
                self.addSubview(sponsoredLabel)
                
                adIconImageView.snp.makeConstraints { (make) in
                    make.left.equalTo(self).offset(10)
                    make.top.equalTo(self).offset(10)
                    make.width.equalTo(adIconImageViewWidth)
                    make.height.equalTo(adIconImageViewHeight)
                    
                }
                
                adTitleLabel.snp.makeConstraints { (make) in
                    make.left.equalTo(adIconImageView.snp.right).offset(10)
                    make.top.equalTo(adIconImageView)
                }
                
                sponsoredLabel.snp.makeConstraints { (make) in
                    make.left.equalTo(adTitleLabel)
                    make.top.equalTo(adTitleLabel.snp.bottom).offset(5)
                    
                }
                
                adChoiceView.snp.makeConstraints { (make) in
                    make.right.equalTo(self).offset(5)
                    make.top.equalTo(self).offset(5)
                }
                
                adCoverMediaView.snp.makeConstraints { (make) in
                    make.left.equalTo(adIconImageView)
                    make.top.equalTo(adIconImageView.snp.bottom).offset(10)
                    make.width.equalTo(adCoverMediaViewWidth)
                    make.height.equalTo(adCoverMediaViewHeight)
                }
                
                adSocialContext.snp.makeConstraints { (make) in
                    make.left.equalTo(adIconImageView)
                    make.top.equalTo(adCoverMediaView.snp.bottom)
                }
                
                adBodyView.snp.makeConstraints { (make) in
                    make.left.equalTo(adIconImageView)
                    make.top.equalTo(adSocialContext.snp.bottom)
                }
                
                adCallToActionButton.snp.makeConstraints { (make) in
                    make.right.equalTo(self).offset(-10)
                    make.top.equalTo(adBodyView.snp.bottom).offset(10)
                }
            }
            
            required init?(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
        }
    }
    
    class InterstitialAds: Ads {
        var adView : FBInterstitialAd?
        
        override func load(in controller: UIViewController){
            super.load(in: controller)
            
            guard let id = id else {
                return
            }
            
            adView = FBInterstitialAd(placementID: id)
            adView?.delegate = delegate as? FBInterstitialAdDelegate
            adView?.load()
        }
        
        override func present(in controller: UIViewController){
            guard let view = adView, view.isAdValid else {
                return
            }
            
            view.show(fromRootViewController: controller)
            load(in: controller)
            
        }
        
        override func check(with adView: Any?) -> Bool {
            return self.adView != nil && self.adView == (adView as? FBInterstitialAd)
        }
    }
}
