//
//  ManageStoreModel.swift
//  MMY
//
//  Created by Apple on 7/28/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import Foundation
import SwiftyJSON

class ManageStoreModel: BaseModel {
    var product_id: String?
    var type: Int?
    var product_type: Int?
    var name: String?
    var price: Int?
    var unit: Int?
    var quantity: Int?
    var description: String?
    var thumbnail: String?
    var end_date: String?
    var address: String?
    var status: Int?
    var user_id: Int?
    var create_date: Int?
    var transport_fee: Int?
    var star: Int?
    var image0: String?
    var image1: String?
    var image2: String?
    
    required init?(json: JSON) {
        super.init(json: json)
        guard json.error == nil else {
            return
        }
        product_id = json["product_id"].stringValue
        type = json["type"].intValue
        product_type = json["product_type"].intValue
        name = json["name"].stringValue
        price = json["price"].intValue
        unit = json["unit"].intValue
        quantity = json["quantity"].intValue
        description = json["description"].stringValue
        end_date = json["end_date"].stringValue
        address = json["address"].stringValue
        status = json["status"].intValue
        user_id = json["user_id"].intValue
        create_date = json["create_date"].intValue
        transport_fee = json["transport_fee"].intValue
        star = json["star"].intValue
        thumbnail = json["thumbnail"].stringValue
        image0 = json["image0"].stringValue
        image1 = json["image1"].stringValue
        image2 = json["image2"].stringValue
    }
}









