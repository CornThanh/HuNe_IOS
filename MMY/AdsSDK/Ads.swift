//
//  Ads.swift
//  SwiftProject1
//
//  Created by Blue R&D on 2/7/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit
import GoogleMobileAds
import SwiftyJSON

class Ads: NSObject {
    
    var controller: UIViewController?
    var delegate: Any?
    var available : Bool?
    
    var adCustomType : AdCustomType?
    var adType : AdType?
    var size : CGSize?
    var adSmartSize : AdsSmartSize?
    var id : String?
    var testIds = [Any]()
    
    init?(json: JSON, delegate: Any?, testIds: [Any]? = nil){
        guard json.error == nil else {
            return nil
        }
        
        adCustomType = AdCustomType(rawValue: json["adCustomType"].stringValue)
        adType = AdType(rawValue: json["adType"].stringValue)
        adSmartSize = AdsSmartSize(rawValue: json["adSmartSize"].stringValue)
        size = CGSize(width: CGFloat(json["width"].floatValue), height: CGFloat(json["height"].floatValue))
        id = json["id"].string
        
        self.delegate = delegate
        if let testIds = testIds{
            self.testIds = testIds
        }
    }
    
    func load(in controller: UIViewController){
        self.controller = controller
    }
    
    func setSize(size : CGSize){
        self.size = size
    }
    
    func setSmartSize(smartSize : AdsSmartSize){
        self.adSmartSize = smartSize
    }
    
    func show(in view: UIView){
    }
    
    func present(in controller: UIViewController){
    }
    
    func check(with adView: Any?) -> Bool{
        return false
    }
}

