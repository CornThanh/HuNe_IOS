//
//  CommentModel.swift
//  MMY
//
//  Created by Apple on 9/11/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit
import SwiftyJSON

class CommentModel: BaseModel {
    var user_id: Int?
    var comment: String?
    var star: Int?
    
    required init?(json: JSON) {
        super.init(json: json)
        user_id = json["user_id"].intValue
        comment = json["comment"].stringValue
        star = json["star"].intValue
    }
}
