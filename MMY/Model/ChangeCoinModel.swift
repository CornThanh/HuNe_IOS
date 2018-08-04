//
//  ChangeCoinModel.swift
//  MMY
//
//  Created by Apple on 8/3/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import SwiftyJSON

class ChangeCoinModel: BaseModel {
    var total_cash: Int?
    var id: Int?
    var balance_cash: Int?
    
    required init?(json: JSON) {
        super.init(json: json)
        total_cash     = json["total_cash"].intValue
        id        =  json["id"].intValue
        balance_cash   = json["balance_cash"].intValue
    }
}
