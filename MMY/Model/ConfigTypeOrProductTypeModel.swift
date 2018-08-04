//
//  ConfigTypeOrProductTypeModel.swift
//  MMY
//
//  Created by Apple on 7/26/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import Foundation
import SwiftyJSON

class ConfigTypeOrProductTypeModel: BaseModel {
    var id: Int?
    var name: String?
    
    required init?(json: JSON) {
        super.init(json: json)
        
        guard json.error == nil else {
            return
        }
        
        id = json["id"].intValue
        name = json["name"].string
    }
}

