//
//  OrderModel.swift
//  MMY
//
//  Created by Apple on 7/28/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import Foundation
import SwiftyJSON

class OrderModel: BaseModel {
    var order_id: String?
    var product_id: String?
    var seller_id: String?
    var buyer_id: String?
    var price: Int?
    var quantity: Int?
    var amount: Int?
    var status: Int?
    var create_date: Int?
    var unit: Int?
    var user_id: Int?
    var seller_name: String?
    var product_type: Int?
    var phone_number: String?
    var type: Int?
    var address: String?
    var name: String?
    var comments_status: Int?
    
    required init?(json: JSON) {
        super.init(json: json)
        guard json.error == nil else {
            return
        }
        order_id = json["order_id"].stringValue
        product_id = json["product_id"].stringValue
        seller_id = json["seller_id"].stringValue
        buyer_id = json["buyer_id"].stringValue
        price = json["price"].intValue
        quantity = json["quantity"].intValue
        amount = json["amount"].intValue
        status = json["status"].intValue
        create_date = json["create_date"].intValue
        unit = json["unit"].intValue
        user_id = json["user_id"].intValue
        seller_name = json["seller_name"].stringValue
        product_type = json["product_type"].intValue
        phone_number = json["phone_number"].stringValue
        type = json["type"].intValue
        address = json["address"].stringValue
        name = json["name"].stringValue
        comments_status = json["comments_status"].intValue
    }
}
