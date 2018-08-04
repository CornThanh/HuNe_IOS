//
//  DetailCoupon.swift
//  MMY
//
//  Created by Apple on 8/3/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import Foundation
import SwiftyJSON

class DetailCouponModel: BaseModel {
    var image : String?
    var price: Int?
    var to_date: String?
    var from_date: String?
    var description: String?
    var coupon_available_count: Int?
    var amount: Int?
    var branch: String?
    var name: String?
    var couponCount: Int?
    
    required init?(json: JSON) {
        super.init(json: json)
        
        image = json["image"].stringValue
        price = json["price"].intValue
        to_date = json["to_date"].stringValue
        from_date = json["from_date"].stringValue
        description = json["description"].stringValue
        coupon_available_count = json["coupon_available_count"].intValue
        amount = json["amount"].intValue
        branch = json["branch"].stringValue
        name = json["name"].stringValue
        couponCount = json["coupon_count"].intValue
    }
}
