//
//  SettingManager.swift
//  MMY
//
//  Created by Blue R&D on 3/21/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit
import SwiftyJSON

class SettingsManager {
    private init() {
        guard let path = Bundle.main.path(forResource: "appConfig", ofType: "json"),
            let data = NSData(contentsOfFile: path) else {
                return
        }
        
        let json        = try! JSON(data: data as Data)
        appURL          = json["appURL"].string ?? ""
        appDescription  = json["appDescription"].string ?? ""
    }
    
    static var shared = SettingsManager()
    
    var appURL = ""
    var appDescription = ""
}
