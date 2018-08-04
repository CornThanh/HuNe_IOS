//
//  BaseFactory.swift
//  SwiftProject1
//
//  Created by Blue R&D on 2/8/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit
import SwiftyJSON
import XCGLogger

class AdsProvider:NSObject {
    var log: XCGLogger?
    var type : AdsProviderType?
    var testIds = [Any]()
    var adHandler: ((Any?, Bool)->Void)?
    
    override init(){
    }
    
    func createNewAd(from json: JSON) -> Ads?{
        return nil
    }
    
    func addTestId(id: String){
        testIds.append(id)
    }
}
