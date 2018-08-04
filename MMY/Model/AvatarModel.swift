//
//  AvatarModel.swift
//  MMY
//
//  Created by Blue R&D on 3/8/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit
import SwiftyJSON

class AvatarModel: BaseModel {
    var createdTime: Int?
    var ext: String?
    var mediaId: String?
    var name: String?
    var type: String?
    var url: String?
    var userId: String?
    
    required init?(json: JSON) {
        super.init(json: json)
        guard json.error == nil else {
            return nil
        }
        
        createdTime = json["createdTime"].int
        ext         = json["ext"].string
        userId      = json["userId"].string
        mediaId     = json["mediaId"].string
        name        = json["name"].string
        type        = json["type"].string
        url         = json["url"].string
        userId      = json["userId"].string
    }
    
    func makeParams() -> [String:Any] {
        var result = [String:Any]()
        result["createdTime"]   = createdTime
        result["ext"]           = ext
        result["mediaId"]       = mediaId
        result["name"]          = name
        result["type"]          = type
        result["url"]           = url
        result["userId"]        = userId
        return result
    }
}
