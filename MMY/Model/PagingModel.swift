//
//  PagingModel.swift
//  MMY
//
//  Created by Blue R&D on 3/13/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit
import SwiftyJSON

class PagingModel: BaseModel {
    var hasMore: Bool?
    var page: Int?
    var nextToken: String?

    required init?(json: JSON) {
        super.init(json: json)
        hasMore     = json["hasMore"].bool
        page        =  json["page"].int
        nextToken   = json["nextToken"].string
    }
    
    func makeParams() -> [String: Any] {
        var result = [String: Any]()
        result["paging"] = ["page": page]
        return result
    }
}
