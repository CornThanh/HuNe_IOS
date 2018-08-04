//
//  AdsManager.swift
//  SwiftProject1
//
//  Created by Blue R&D on 2/8/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit
import SwiftyJSON
import XCGLogger
import SnapKit

class AdsManager: NSObject {
    var log = XCGLogger(identifier: "AdsManager", includeDefaultDestinations: true)
    var providers = [AdsProvider]()
    var ads = [Ads]()
    var availableHandler: ((AdCustomType, Bool)->Void)?
    static var sharedInstance : AdsManager = AdsManager()
    
    override private init(){
        log.setup(level: .debug, showLogIdentifier: true)
    }
    
    //MARK: - Publics
    func addProvider(provider: AdsProvider?){
        if let provider = provider{
            provider.log = log
            providers.append(provider)
        }
    }
    
    func setLogLevel(_ level: XCGLogger.Level) {
        log.outputLevel = level
    }
    
    func loadAllAds(in controller: UIViewController){
        ads.removeAll()
        
        loadAdsInJSONFile()
        
        for ad in ads{
            load(ad: ad, in: controller)
        }
        
        setProviderCallback()
    }
    
    func showAds(customType: AdCustomType,
                 normalAdSize: CGSize? = nil,
                 smartSize: AdsSmartSize = .smartPortrait,
                 inView: UIView? = nil,
                 inController: UIViewController? = nil)  {
        
        for ad in ads{
            if ad.adCustomType == customType{
                
                if let size = normalAdSize{
                    ad.setSize(size: size)
                }
                
                ad.adSmartSize = smartSize
                
                if let view = inView{
                    ad.show(in: view)
                }
                
                if let controller = inController{
                    ad.present(in: controller)
                }
            }
        }
    }
    
    func checkAdAvailable(with customType: AdCustomType) -> Bool{
        for ad in ads{
            if ad.adCustomType == customType{
                return ad.available ?? false
            }
        }
        
        return false
    }
    
    
    //MARK - Privates
    private func setProviderCallback(){
        for provider in providers{
            provider.adHandler = {(ad, available) in
                self.setAd(has: ad, with: available)
            }
        }
    }
    
    private func getProvider(with type: AdsProviderType?) -> AdsProvider?{
        guard let type = type else {
            return nil
        }
        
        for provider in providers{
            if provider.type == type{
                return provider
            }
        }
        
        return nil
    }
    
    private func loadAdsInJSONFile(){
            guard let path = Bundle.main.path(forResource: "ads", ofType: "json"),
                let data = NSData(contentsOfFile: path) else {
                    return
            }
            
        let json = try! JSON(data: data as Data)
            
            loadTestIds(from: json["testDeviceIds"])
            loadAds(from: json)
    }
    
    private func loadTestIds(from json:JSON){
        if json["enable"] == false{
            return
        }
        
        for testId in json["ids"].arrayValue{
            if let providerType = AdsProviderType(rawValue: testId["provider"].stringValue),
                let provider = getProvider(with: providerType){
                provider.addTestId(id: testId["id"].stringValue)
            }
        }
    }
    
    private func loadAds(from json:JSON){
        for item in json["ads"].arrayValue {
            if let providerType = AdsProviderType(rawValue: item["provider"].stringValue),
                let provider = getProvider(with: providerType),
                let ad = provider.createNewAd(from: item) {
                
                ads.append(ad) 
            }
        }
    }
    
    private func load(ad: Ads, in controller: UIViewController)  {
        ad.load(in: controller)
    }
    
    private func getAdReceivedDelegate(with targetView: Any?) -> Ads?{
        for ad in ads{
            if ad.check(with: targetView){
                return ad
            }
        }
        return nil
    }
    
    private func setAd(has targetView: Any?, with available: Bool ){
        let targetAd = getAdReceivedDelegate(with: targetView)
        targetAd?.available = available
        
        if let customType = targetAd?.adCustomType{
            availableHandler?(customType, available)
        }
    }
}
