//
//  ProductEditModel.swift
//  MMY
//
//  Created by Apple on 9/11/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit
import SwiftyJSON

class ProductEditModel: BaseModel {
    var product_id: String?
    var comments = [CommentModel]()
    var star: Int?
    
    required init?(json: JSON) {
        super.init(json: json)
        product_id = json["product_id"].stringValue
        star = json["star"].intValue
        
        for data in json["comments"].arrayValue {
            let comment  = CommentModel(json: data)
            comments.append(comment!)
        }
    }
}
