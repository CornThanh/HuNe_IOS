//
//  BannerPromotionModel.swift
//  MMY
//
//  Created by Apple on 8/3/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import Foundation
import SwiftyJSON

class BannerPromotionModel: BaseModel {
    var id: String?
    var position: Int?
    var cover: String?
    var url: String?
    
    required init?(json: JSON) {
        super.init(json: json)
        guard json.error == nil else {
            return nil
        }
        id = json["id"].stringValue
        position = json["position"].intValue
        cover = json["cover"].stringValue
        url = json["url"].stringValue
    }
    
}
