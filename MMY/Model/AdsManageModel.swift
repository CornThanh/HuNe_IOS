//
//  AdsManageModel.swift
//  MMY
//
//  Created by Apple on 8/3/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import Foundation
import SwiftyJSON

class AdsManageModel: BaseModel {
    var name: String?
    var price: String?
    var amount: Int?
    var positition: String?
    var status: Int?
    var type: Int?
    
    required init?(json: JSON) {
        super.init(json: json)
        guard json.error == nil else {
            return nil
        }
        name = json["name"].string
        price = json["price"].string
        amount = json["amount"].int
        positition = json["positition"].string
        status = json["status"].int
        type = json["type"].int
    }
    
}

