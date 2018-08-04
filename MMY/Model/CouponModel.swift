//
//  CouponModel.swift
//  MMY
//
//  Created by Nguyen Minh Phuong on 1/31/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import Foundation
import SwiftyJSON

//amount = 100000;
//branch = "<null>";
//"branch_html" = "<ul><li></li></ul>";
//"created_at" = "2018-01-25 16:45:11";
//description = "Nh\U1eadp m\U00e3 n\U00e0y khi thanh to\U00e1n ch\U1ea1y ads qu\U1ea3ng c\U00e1o tr\U00ean HuNe app s\U1ebd \U0111\U01b0\U1ee3c gi\U1ea3m ngay 100k.";
//"description_html" = "<ul><li>Nh\U1eadp m\U00e3 n\U00e0y khi thanh to\U00e1n ch\U1ea1y ads qu\U1ea3ng c\U00e1o tr\U00ean HuNe app s\U1ebd \U0111\U01b0\U1ee3c gi\U1ea3m ngay 100k.</li></ul>";
//"for_ads" = 2;
//"from_date" = "2018-01-25 00:00:00";
//id = 33;
//image = "https://hunegroup.com/storage/upload/2018/01/25/1516874240.jpeg";
//name = "T\U1eb7ng m\U00e3 ch\U1ea1y HuNe ads 100k";
//"partner_id" = 1;
//price = 35000;
//"to_date" = "2018-02-16 00:00:00";
//"type_discount" = 1;
//"updated_at" = "2018-01-25 16:57:20";

class CouponModel: BaseModel {
    var id: Int?
    var price: Int?
    var name: String?
    var imageUrl: String?
    var fromDate: String?
    var toDate: String?
    var detail: String?
    var detailHtlm: String?
    var imageListCoupon: String?
    var adsBranch = [AdsBranch]()
    
    required init?(json: JSON) {
        super.init(json: json)
        guard json.error == nil else {
            return nil
        }
        
        id          = json["id"].int
        name        = json["name"].string
        imageUrl      = json["logo"].string
        fromDate    = json["from_date"].string
        toDate      = json["to_date"].string
        detail      = json["description"].string
        detailHtlm  = json["description_html"].string
        price       = json["price"].int
        imageListCoupon = json["image"].string
        for data in json["ads_branch"].arrayValue {
            let ads  = AdsBranch(json: data)
            adsBranch.append(ads!)
        }
        
    }
    
}

class MyCouponModel: BaseModel {
    var code: String?
    var coupon : CouponModel?
    
    required init?(json: JSON) {
        super.init(json: json)
        guard json.error == nil else {
            return nil
        }
        code    = json["code"].string
        coupon  = CouponModel(json: json["coupon_group"])
    }
}

class AdsBranch: BaseModel {
    var id: Int?
    var name: String?
    
    
    required init?(json: JSON) {
        super.init(json: json)
        guard json.error == nil else {
            return nil
        }
        
        id = json["id"].intValue
        name = json["name"].stringValue
    }
}
